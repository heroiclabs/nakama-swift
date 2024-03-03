/*
 * Copyright © 2024 The Satori Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import GRPC
import NIO
import Logging
import SwiftProtobuf

/// A client to interact with the API in Satori server.
public class Client: ClientProtocol {
    public let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    public let defaultExpiredTimeSpan: TimeInterval = 5 * 60
    public var retriesLimit = 5
    
    public var autoRefreshSession: Bool
    public var globalRetryConfiguration: RetryConfiguration

    public let host: String
    public let port: Int
    public let ssl: Bool
    public let apiKey: String
    public let transientErrorAdapter: TransientErrorAdapter?

    private let grpcConnection: ClientConnection
    private let satoriGrpcClient: Satori_Api_SatoriClientProtocol
    private let retryInvoker: RetryInvoker
    private var logger: Logger?

    /// Initialize a new client.
    public init(host: String = "127.0.0.1", port: Int = 7450, ssl: Bool = false, apiKey: String, autoRefreshSession: Bool = true, transientErrorAdapter: TransientErrorAdapter? = nil, deadlineAfter: TimeInterval = 20.0, keepAliveTimeout: TimeAmount = .seconds(20), trace: Bool = false) {
        let base64Auth = "\(apiKey):".data(using: String.Encoding.utf8)!.base64EncodedString()
        let basicAuth = "Basic \(base64Auth)"
        var callOptions = CallOptions(cacheable: false)
        callOptions.customMetadata.add(name: "authorization", value: basicAuth)

        var configuration = ClientConnection.Configuration.default(target: .hostAndPort(host, port), eventLoopGroup: self.eventLoopGroup)
        configuration.connectionBackoff = ConnectionBackoff(minimumConnectionTimeout: deadlineAfter, retries: .upTo(retriesLimit))
        configuration.connectionKeepalive = ClientConnectionKeepalive(timeout: keepAliveTimeout, permitWithoutCalls: true)
        configuration.callStartBehavior = .fastFailure
        
        if ssl {
            configuration.tlsConfiguration = .init(GRPCTLSConfiguration.makeClientDefault(compatibleWith: eventLoopGroup))
        }
        
        if trace {
            logger = Logger(label: "com.heroiclabs.nakama-swift.satori")
            configuration.backgroundActivityLogger = logger!
            callOptions.logger = logger!
        }
        
        logger?.debug("Dialing grpc server \(host):\(port) with basic auth \(basicAuth)")
        
        self.host = host
        self.port = port
        self.ssl = ssl
        self.apiKey = apiKey
        self.transientErrorAdapter = transientErrorAdapter ?? TransientErrorAdapter()
        self.autoRefreshSession = autoRefreshSession
        self.retryInvoker = RetryInvoker(transientErrorAdapter: transientErrorAdapter!)
        self.globalRetryConfiguration = RetryConfiguration(baseDelayMs: 500, maxRetries: 4)
        self.grpcConnection = ClientConnection(configuration: configuration)
        self.satoriGrpcClient = Satori_Api_SatoriNIOClient(channel: grpcConnection, defaultCallOptions: callOptions)
    }

    /// Close the client.
    public func close() async throws {
        return try await self.grpcConnection.close().get()
    }

    public func authenticateAsync(id: String, defaultProperties: [String : String]?, customProperties: [String : String]?, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Satori_Api_AuthenticateRequest()
        req.id = id
        if let defaultProperties {
            req.default = defaultProperties
        }
        if let customProperties {
            req.custom = customProperties
        }
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.satoriGrpcClient.authenticate(req).response.get().toSession()
        }, history: RetryHistory(token: id, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func authenticateLogoutAsync(session: Session, retryConfig: RetryConfiguration? = nil) async throws -> Void {
        var req = Satori_Api_AuthenticateLogoutRequest()
        req.token = session.authToken
        req.refreshToken = session.refreshToken
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.satoriGrpcClient.authenticateLogout(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func sessionRefreshAsync(session: Session, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Satori_Api_AuthenticateRefreshRequest()
        req.refreshToken = session.refreshToken
        
        let newSession = try await retryInvoker.invokeWithRetry(request: {
            try await self.satoriGrpcClient.authenticateRefresh(req, callOptions: session.callOptions).response.get().toSession()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
        
        if let updatedSession = session as? SatoriSession {
            updatedSession.update(authToken: newSession.authToken, refreshToken: newSession.refreshToken)
            return updatedSession
        }
        
        return SatoriSession(authToken: newSession.authToken, refreshToken: newSession.refreshToken)
    }

    public func eventAsync(session: Session, event: Event, retryConfig: RetryConfiguration? = nil) async throws -> Void {
        var req = Satori_Api_EventRequest()
        req.events = [event.toApiEvent()]
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.satoriGrpcClient.event(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func eventsAsync(session: Session, events: [Event], retryConfig: RetryConfiguration? = nil) async throws -> Void {
        var req = Satori_Api_EventRequest()
        req.events = events.map { $0.toApiEvent() }
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.satoriGrpcClient.event(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func getAllExperimentsAsync(session: Session, retryConfig: RetryConfiguration? = nil) async throws -> Satori_Api_ExperimentList {
        let req = Satori_Api_GetExperimentsRequest()
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.satoriGrpcClient.getExperiments(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func getExperimentsAsync(session: Session, names: [String], retryConfig: RetryConfiguration? = nil) async throws -> Satori_Api_ExperimentList {
        var req = Satori_Api_GetExperimentsRequest()
        req.names = names
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.satoriGrpcClient.getExperiments(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func getFlagAsync(session: Session, name: String, defaultValue: String? = "", retryConfig: RetryConfiguration? = nil) async throws -> Satori_Api_Flag {
        var req = Satori_Api_GetFlagsRequest()
        req.names = [name]
        return try await retryInvoker.invokeWithRetry(request: {
            let flags = try await self.satoriGrpcClient.getFlags(req, callOptions: session.callOptions).response.get()
            guard let flag = flags.flags.first(where: { $0.name == name }) else {
                throw SatoriError.noMatchingFlag
            }
            return flag
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func getFlagsAsync(session: Session, names: [String], retryConfig: RetryConfiguration? = nil) async throws -> Satori_Api_FlagList {
        var req = Satori_Api_GetFlagsRequest()
        req.names = names
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.satoriGrpcClient.getFlags(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func getLiveEventsAsync(session: Session, names: [String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Satori_Api_LiveEventList {
        var req = Satori_Api_GetLiveEventsRequest()
        req.names = names ?? []
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.satoriGrpcClient.getLiveEvents(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func identifyAsync(session: Session, id: String, defaultProperties: [String : String], customProperties: [String : String], retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Satori_Api_IdentifyRequest()
        req.id = id
        req.default = defaultProperties
        req.custom = customProperties
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.satoriGrpcClient.identify(req, callOptions: session.callOptions).response.get().toSession()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func listPropertiesAsync(session: Session, retryConfig: RetryConfiguration? = nil) async throws -> Satori_Api_Properties {
        let req = Google_Protobuf_Empty()
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.satoriGrpcClient.listProperties(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func updatePropertiesAsync(session: Session, defaultProperties: [String : String], customProperties: [String : String], recompute: Bool? = false, retryConfig: RetryConfiguration? = nil) async throws -> Void {
        var req = Satori_Api_UpdatePropertiesRequest()
        req.default = defaultProperties
        req.custom = customProperties
        req.recompute = (recompute ?? false).toProtobufBool()
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.satoriGrpcClient.updateProperties(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }

    public func deleteIdentityAsync(session: Session, retryConfig: RetryConfiguration? = nil) async throws -> Void {
        var req = Google_Protobuf_Empty()
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.satoriGrpcClient.deleteIdentity(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(token: session.authToken, configuration: retryConfig ?? globalRetryConfiguration))
    }
}

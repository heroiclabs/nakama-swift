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
import Logging
import GRPC

/// A closure type representing a handler for transient errors.
public typealias TransientErrorHandler = (Error) -> Bool

/// A `REST` client for the API in Satori server.
public class HttpClient: HttpClientProtocol {
    public let scheme: String
    public let host: String
    public let port: Int
    public let apiKey: String
    public let autoRefreshSession: Bool
    public var globalRetryConfiguration: RetryConfiguration
    
    private let apiClient: ApiClient
    private let retryInvoker: RetryInvoker
    private var logger: Logger?
    
    public init(scheme: String = "http", host: String = "127.0.0.1", port: Int = 7450, apiKey: String, autoRefreshSession: Bool = true) {
        self.scheme = scheme
        self.host = host
        self.port = port
        self.apiKey = apiKey
        self.autoRefreshSession = autoRefreshSession
        self.retryInvoker = RetryInvoker(handler: { error in
            if let e = error as? ApiResponseError {
                return e.statusCode == 500 || e.statusCode == 502 || e.statusCode == 503 || e.statusCode == 504
            }
            return false
        })
        self.globalRetryConfiguration = RetryConfiguration(baseDelayMs: 500, maxRetries: 4)
        self.logger = Logger(label: "com.heroiclabs.nakama-swift.satori")
        
        guard let url = URL(string: "\(scheme)://\(host):\(port)") else {
            fatalError("Invalid url is used")
        }
        self.apiClient = ApiClient(baseUri: url, httpAdapter: HttpRequestAdapter(logger: self.logger))
    }
    
    public func authenticate(id: String, defaultProperties: [String : String]? = nil, customProperties: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        let req = ApiAuthenticateRequest(id: id)
        if let defaultProperties {
            req.default_ = defaultProperties
        }
        if let customProperties {
            req.custom = customProperties
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.apiClient.SatoriAuthenticate(basicAuthUsername: self.apiKey, basicAuthPassword: "", body: req).toSession()
        }, history: RetryHistory(token: id, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func authenticateLogout(session: Session, retryConfig: RetryConfiguration? = nil) async throws {
        let req = ApiAuthenticateLogoutRequest(refreshToken: session.refreshToken, token: session.authToken)
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriAuthenticateLogout(bearerToken: session.authToken, body: req)
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func sessionRefresh(session: Session, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        let req = ApiAuthenticateRefreshRequest(refreshToken: session.refreshToken)
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.apiClient.SatoriAuthenticateRefresh(basicAuthUsername: self.apiKey, basicAuthPassword: "", body: req).toSession()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func event(session: Session, event: Event, retryConfig: RetryConfiguration? = nil) async throws {
        let req = ApiEventRequest()
        req.events = [event.toApiEvent()]
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriEvent(bearerToken: session.authToken, body: req)
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func events(session: Session, events: [Event], retryConfig: RetryConfiguration? = nil) async throws {
        let request = ApiEventRequest()
        request.events = events.map { $0.toApiEvent() }
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriEvent(bearerToken: session.authToken, body: request)
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getAllExperiments(session: Session, retryConfig: RetryConfiguration? = nil) async throws -> ExperimentList {
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriGetExperiments(bearerToken: session.authToken, names: []).toExperimentList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getExperiments(session: Session, names: [String], retryConfig: RetryConfiguration? = nil) async throws -> ExperimentList {
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriGetExperiments(bearerToken: session.authToken, names: names).toExperimentList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getFlag(session: Session, name: String, defaultValue: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Flag {
        return try await retryInvoker.invokeWithRetry(request: {
            do {
                let response = try await self.apiClient.SatoriGetFlags(bearerToken: session.authToken, basicAuthUsername: self.apiKey, basicAuthPassword: "", names: [name])
                // Return only the first flag that matches the name
                if let flag = response.flags?.first(where: { $0.name == name }) {
                    return flag.toFlag()
                }
                
                if let defaultValue {
                    return ApiFlag(conditionChanged: false, name: name, value: defaultValue).toFlag()
                }
            } catch {
                // Return default value if provided
                if let defaultValue {
                    return ApiFlag(conditionChanged: false, name: name, value: defaultValue).toFlag()
                }
            }
            
            throw SatoriError.noMatchingFlag
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getFlags(session: Session, names: [String], retryConfig: RetryConfiguration? = nil) async throws -> FlagList {
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriGetFlags(bearerToken: session.authToken, basicAuthUsername: self.apiKey, basicAuthPassword: "", names: names).toFlagList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getLiveEvents(session: Session, names: [String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> LiveEventList {
        return try await  retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriGetLiveEvents(bearerToken: session.authToken, names: names ?? []).toLiveEventList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func identify(session: Session, id: String, defaultProperties: [String : String], customProperties: [String : String], retryConfig: RetryConfiguration? = nil) async throws -> Session {
        let req = ApiIdentifyRequest(id: id)
        req.default_ = defaultProperties
        req.custom = customProperties
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriIdentify(bearerToken: session.authToken, body: req).toSession()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listProperties(session: Session, retryConfig: RetryConfiguration? = nil) async throws -> Properties {
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriListProperties(bearerToken: session.authToken).toProperties()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func updateProperties(session: Session, defaultProperties: [String : String], customProperties: [String : String], recompute: Bool? = false, retryConfig: RetryConfiguration? = nil) async throws {
        let req = ApiUpdatePropertiesRequest(recompute: recompute ?? false)
        req.default_ = defaultProperties
        req.custom = customProperties
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriUpdateProperties(bearerToken: session.authToken, body: req)
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func deleteIdentity(session: Session, retryConfig: RetryConfiguration? = nil) async throws {
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriDeleteIdentity(bearerToken: session.authToken)
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
}

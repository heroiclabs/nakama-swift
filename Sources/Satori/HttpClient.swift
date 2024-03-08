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

public class HttpClient: HttpClientProtocol {
	public let scheme: String
    public let host: String
    public let port: Int
	public let apiKey: String
    public let autoRefreshSession: Bool
    public let transientErrorAdapter: TransientErrorHttpAdapter
    public var globalRetryConfiguration: RetryConfiguration

	private let apiClient: ApiClient
	private let retryInvoker: RetryInvoker
	private var logger: Logger?
    
    init(scheme: String = "http", host: String = "127.0.0.1", port: Int = 7450, apiKey: String, autoRefreshSession: Bool = true, transientErrorAdapter: TransientErrorHttpAdapter? = nil) {
		self.scheme = scheme
        self.host = host
        self.port = port
        self.apiKey = apiKey
        self.autoRefreshSession = autoRefreshSession
        self.transientErrorAdapter = transientErrorAdapter ?? TransientErrorHttpAdapter()
        self.retryInvoker = RetryInvoker(transientErrorAdapter: self.transientErrorAdapter)
        self.globalRetryConfiguration = RetryConfiguration(baseDelayMs: 500, maxRetries: 4)
        self.logger = Logger(label: "com.heroiclabs.nakama-swift.satori")

        guard let url = URL(string: "\(scheme)://\(host):\(port)") else {
            fatalError("Invalid url is used")
        }
        self.apiClient = ApiClient(baseUri: url, httpAdapter: HttpRequestAdapter(logger: self.logger))
    }
    
    public func authenticate(id: String, defaultProperties: [String : String]? = nil, customProperties: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> ApiSession {
        let req = ApiAuthenticateRequest(id: id)
        if let defaultProperties {
            req.default_ = defaultProperties
        }
        if let customProperties {
            req.custom = customProperties
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriAuthenticate(basicAuthUsername: self.apiKey, basicAuthPassword: "", body: req)
        }, history: RetryHistory(token: id, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func authenticateLogout(session: ApiSession, retryConfig: RetryConfiguration? = nil) async throws {
        let req = ApiAuthenticateLogoutRequest(refreshToken: session.refreshToken, token: session.token)
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriAuthenticateLogout(bearerToken: session.token, body: req)
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func sessionRefresh(session: ApiSession, retryConfig: RetryConfiguration? = nil) async throws -> ApiSession {
        let req = ApiAuthenticateRefreshRequest(refreshToken: session.refreshToken)
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriAuthenticateRefresh(basicAuthUsername: self.apiKey, basicAuthPassword: "", body: req)
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func event(session: ApiSession, event: Event, retryConfig: RetryConfiguration? = nil) async throws {
        let req = ApiEventRequest()
        req.events = [event.toApiEvent()]
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriEvent(bearerToken: session.token, body: req)
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func events(session: ApiSession, events: [Event], retryConfig: RetryConfiguration? = nil) async throws {
        let request = ApiEventRequest()
        request.events = events.map { $0.toApiEvent() }
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriEvent(bearerToken: session.token, body: request)
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getAllExperiments(session: ApiSession, retryConfig: RetryConfiguration? = nil) async throws -> ApiExperimentList {
        try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriGetExperiments(bearerToken: session.token, names: [])
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getExperiments(session: ApiSession, names: [String], retryConfig: RetryConfiguration? = nil) async throws -> ApiExperimentList {
        try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriGetExperiments(bearerToken: session.token, names: names)
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getFlag(session: ApiSession, name: String, defaultValue: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> ApiFlag {
        return try await retryInvoker.invokeWithRetry(request: {
            do {
                let response = try await self.apiClient.SatoriGetFlags(bearerToken: session.token, basicAuthUsername: self.apiKey, basicAuthPassword: "", names: [name])
                // Return only the first flag that matches the name
                if let flag = response.flags?.first(where: { $0.name == name }) {
                    return flag
                }
                
                if let defaultValue {
                    return ApiFlag(conditionChanged: false, name: name, value: defaultValue)
                }
            } catch {
                // Return default value if provided
                if let defaultValue {
                    return ApiFlag(conditionChanged: false, name: name, value: defaultValue)
                }
            }
            
            throw SatoriError.noMatchingFlag
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getFlags(session: ApiSession, names: [String], retryConfig: RetryConfiguration? = nil) async throws -> ApiFlagList {
        try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriGetFlags(bearerToken: session.token, basicAuthUsername: self.apiKey, basicAuthPassword: "", names: names)
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getLiveEvents(session: ApiSession, names: [String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> ApiLiveEventList {
        let response = try await apiClient.SatoriGetLiveEvents(bearerToken: session.token, names: names ?? [])
        return response
    }
    
    public func identify(session: ApiSession, id: String, defaultProperties: [String : String], customProperties: [String : String], retryConfig: RetryConfiguration? = nil) async throws -> ApiSession {
        let req = ApiIdentifyRequest(id: id)
        req.default_ = defaultProperties
        req.custom = customProperties
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriIdentify(bearerToken: session.token, body: req)
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listProperties(session: ApiSession, retryConfig: RetryConfiguration? = nil) async throws -> ApiProperties {
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriListProperties(bearerToken: session.token)
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func updateProperties(session: ApiSession, defaultProperties: [String : String], customProperties: [String : String], recompute: Bool? = false, retryConfig: RetryConfiguration? = nil) async throws {
        let req = ApiUpdatePropertiesRequest(recompute: recompute ?? false)
        req.default_ = defaultProperties
        req.custom = customProperties
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriUpdateProperties(bearerToken: session.token, body: req)
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func deleteIdentity(session: ApiSession, retryConfig: RetryConfiguration? = nil) async throws {
        return try await retryInvoker.invokeWithRetry(request: {
            try await self.apiClient.SatoriDeleteIdentity(bearerToken: session.token)
        }, history: RetryHistory(session: session.toSession(), configuration: retryConfig ?? globalRetryConfiguration))
    }
}

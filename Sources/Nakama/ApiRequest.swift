/*
 * Copyright © 2026 The Nakama Authors
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

public enum HttpMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public struct ApiRequest<Response: Decodable>: Sendable {
    public let method: HttpMethod
    public let path: String
    public let queryItems: [URLQueryItem]
    public let body: Data?

    public init(method: HttpMethod, path: String, queryItems: [URLQueryItem] = [], body: Data? = nil) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.body = body
    }

    public func url(relativeTo baseUri: URL) throws -> URL {
        var components = URLComponents()
        components.scheme = baseUri.scheme
        components.host = baseUri.host
        components.port = baseUri.port
        components.path = path
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }
}

/// Modeled after google.protobuf.Empty, with no body.
public struct EmptyResponse: Codable, Sendable {
    public init() {}
}

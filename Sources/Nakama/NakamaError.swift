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

public final class ApiResponseError: Error, Decodable, CustomStringConvertible {
    public let grpcStatusCode: Int
    public let message: String
    public var statusCode: Int?

    public init(grpcStatusCode: Int, message: String, statusCode: Int? = nil) {
        self.grpcStatusCode = grpcStatusCode
        self.message = message
        self.statusCode = statusCode
    }

    private enum CodingKeys: String, CodingKey {
        case grpcStatusCode = "code"
        case message
    }

    public var description: String {
        "ApiResponseError(StatusCode=\(statusCode.map(String.init) ?? "nil"), "
            + "Message='\(message)', GrpcStatusCode=\(grpcStatusCode))"
    }
}

/// Errors raised by the client itself, before or instead of a server round trip.
public enum NakamaError: Error, Equatable {
    case invalidServerUri(String)
    case invalidSessionToken
    case sessionExpired
    case unexpectedResponse(statusCode: Int)
    case socketNotConnected
    case unexpectedRealtimeReply
}


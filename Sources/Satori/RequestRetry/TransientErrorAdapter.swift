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

/// A closure type representing a handler for transient errors.
public typealias TransientErrorHandler = (Error) -> Bool

enum TransientErrorResponseType {
    case ServerOk
    case TransientError
    case NonTransientError
}

protocol TransientErrorProtocol {
    /// A closure that takes an error as input and returns a boolean.
    /// Used to determine whether or not a network exception is due to a temporary bad state on the server.
    ///
    /// For example, timeouts can be transient in cases where the server is experiencing temporarily high load.
    var handler: TransientErrorHandler { get }
    
    func sendAsync<T>(request: @escaping () async throws -> T) async throws -> T
}
extension TransientErrorProtocol {
    func sendAsync<T>(request: @escaping () async throws -> T) async throws -> T {
        return try await request()
    }
}

/// An adapter used to intercept errors and determine if they are transient or not.
public class TransientErrorAdapter: TransientErrorProtocol {
    var handler: TransientErrorHandler {
        return { error in
            if let e = error as? GRPCStatus {
                return e.code == .internalError || e.code == .unavailable
            }
            return false
        }
    }
}

/// An http adapter to intercept errors and determine if they are transient or not.
public class TransientErrorHttpAdapter: TransientErrorProtocol {
    var handler: TransientErrorHandler {
        return { error in
            if let e = error as? ApiResponseError {
                return e.statusCode == 500 || e.statusCode == 503
            }
            return false
        }
    }
}

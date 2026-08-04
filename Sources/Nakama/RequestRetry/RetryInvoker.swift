/*
 * Copyright © 2023 Heroic Labs
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

/// - Parameter retries: The number of retries made so far, including this one.
/// - Parameter retry: Information about the retry attempt.
public typealias RetryListener = @Sendable (_ retries: Int, _ retry: Retry) -> Void

/// Decides whether an error is due to a temporary bad state on the server, and so worth
/// retrying. Timeouts and 503s are transient; a 400 is not.
public typealias TransientErrorHandler = @Sendable (Error) -> Bool

public enum RetryInvokerError: Error, Equatable {
    case exceededRetries(String)
}

/// Invokes requests with retry and exponential backoff.
struct RetryInvoker {
    private let isTransient: TransientErrorHandler

    init(handler: @escaping TransientErrorHandler) {
        self.isTransient = handler
    }

    func invokeWithRetry<T>(
        request: () async throws -> T,
        configuration: RetryConfiguration
    ) async throws -> T {
        var retries = [Retry]()

        while true {
            do {
                return try await request()
            } catch {
                guard isTransient(error) else { throw error }
                guard retries.count < configuration.maxRetries else {
                    throw RetryInvokerError.exceededRetries("Exceeded max retry attempts")
                }

                let interval = configuration.baseDelay * Int(pow(2, Double(retries.count)))
                let retry = Retry(
                    exponentialBackoff: interval,
                    jitterBackoff: configuration.jitter(retries, interval)
                )
                retries.append(retry)
                configuration.retryListener(retries.count, retry)

                try await Task.sleep(nanoseconds: UInt64(retry.jitterBackoff) * 1_000_000)
            }
        }
    }
}

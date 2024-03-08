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

/**
 Listens to retry events for a particular request.
 - Parameter retries: The number of retries made so far, including this retry.
 - Parameter retry: A `Retry` object holding information about the retry attempt.
 */
public typealias RetryListener = (_ retries: Int, _ retry: Retry) -> Void

enum RetryInvokerError: Error {
    case invalidArgument(String)
    case exceededRetries(String)
    
    init(_ message: String) {
        self = .invalidArgument(message)
    }
}

/// Invokes requests with retry and exponential backoff.
public final class RetryInvoker {
    private let transientErrorAdapter: TransientErrorProtocol
    
    init(transientErrorAdapter: TransientErrorProtocol) {
        self.transientErrorAdapter = transientErrorAdapter
    }
    
    public func invokeWithRetry<T>(request: @escaping () async throws -> T, history: RetryHistory) async throws -> T {
        do {
            return try await transientErrorAdapter.sendAsync(request: request)
        } catch {
            guard history.configuration != nil, transientErrorAdapter.handler(error) else {
                throw error
            }
            
            try await backoffDelay(history: history, error: error)
            return try await invokeWithRetry(request: request, history: history)
        }
    }
    
    private func backoffDelay(history: RetryHistory, error: Error) async throws {
        guard history.retries.count < history.configuration!.maxRetries else {
            throw RetryInvokerError.exceededRetries("Exceeded max retry attempts")
        }
        
        let retry = createRetry(from: history)
        history.retries.append(retry)
        history.configuration?.retryListener(history.retries.count, retry)
        
        try await backoff(retry.jitterBackoff)
    }
    
    private func createRetry(from history: RetryHistory) -> Retry {
        let baseDelay = history.configuration!.baseDelay
        let retryInterval = baseDelay * Int(pow(2, Double(history.retries.count)))
        let jitterBackoff = history.configuration!.jitter(history.retries, retryInterval, history.random)
        return Retry(exponentialBackoff: retryInterval, jitterBackoff: jitterBackoff)
    }
    
    private func backoff(_ jitterBackoff: Int) async throws {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(jitterBackoff)) {
                continuation.resume()
            }
        }
    }
}

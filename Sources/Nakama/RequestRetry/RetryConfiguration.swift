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

/// Controls retriable requests. Set on the client as `globalRetryConfiguration`, or passed
/// per-request via the trailing `retryConfig:` parameter, which takes precedence.
public final class RetryConfiguration {
    /// Base delay in milliseconds, raised to the power of the retry attempt number.
    public var baseDelay: Int

    /// Maximum number of attempts to make before cancelling the request.
    public var maxRetries: Int

    /// Applies randomness to the retry delay. Defaults to `RetryJitter.fullJitter`.
    public var jitter: Jitter

    /// Invoked before each new retry attempt.
    public var retryListener: RetryListener

    public init(baseDelayMs: Int, maxRetries: Int, jitter: Jitter? = nil, retryListener: RetryListener? = nil) {
        self.baseDelay = baseDelayMs
        self.maxRetries = maxRetries
        self.jitter = jitter ?? { retries, delayMs in
            RetryJitter.fullJitter(retries: retries, retryDelay: delayMs)
        }
        self.retryListener = retryListener ?? { _, _ in }
    }
}

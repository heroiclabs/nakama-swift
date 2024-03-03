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
 A configuration for controlling retriable requests.
 
 Configurations can be assigned to the `Client` on a request-by-request basis via `RequestConfiguration`.
 
 It can also be assigned on a global basis using `GlobalRetryConfiguration`.
 
 Configurations passed via the `RequestConfiguration` parameter take precedence over the global configuration.
 */
public final class RetryConfiguration {
    /**
     The base delay (milliseconds) used to calculate the time before making another request attempt.
     This base will be raised to N, where N is the number of retry attempts.
     */
    var baseDelay: Int
    
    /// The maximum number of attempts to make before cancelling the request task.
    var maxRetries: Int
    
    /// The jitter algorithm used to apply randomness to the retry delay. Defaults to `FullJitter`
    var jitter: Jitter
    
    /// A closure that is invoked before a new retry attempt is made.
    var retryListener: RetryListener
    
    public init(baseDelayMs: Int, maxRetries: Int, jitter: Jitter? = nil, retryListener: RetryListener? = nil) {
        self.baseDelay = baseDelayMs
        self.maxRetries = maxRetries
        self.jitter = jitter ?? { retries, delayMs, random in
            return RetryJitter.fullJitter(retries: retries, retryDelay: delayMs, random: random)
        }
        self.retryListener = retryListener ?? { retriesCount, retry in
            
        }
    }
}

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

/**
 The Jitter algorithm is responsible for introducing randomness to a delay before a retry.
 - Parameter history: Information about previous retry attempts.
 - Parameter delay: A delay (milliseconds) between the last failed attempt in the retry history and the next upcoming attempt.
 */
public typealias Jitter = @Sendable (_ history: [Retry], _ delay: Int) -> Int

/// A collection of Jitter algorithms.
public struct RetryJitter {
    /// A jitter algorithm that selects a random point between now and the next retry time.
    public static func fullJitter(retries: [Retry], retryDelay: Int) -> Int {
        Int(Double(retryDelay) * Double.random(in: 0..<1))
    }
}

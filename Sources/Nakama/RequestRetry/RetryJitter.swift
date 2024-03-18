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
 - Parameter delay: A delay (milliseconds) between the last failed attempt in the retry history  and the next upcoming attempt.
 - Parameter random: A seeded random number generator.
 */
public typealias Jitter = (_ history: [Retry], _ delay: Int, _ random: NakamaRandomGenerator) -> Int

/// A collection of Jitter algorithms.
struct RetryJitter {
     /// A jitter algorithm that selects a random point between now and the next retry time.
    static func fullJitter(retries: [Retry], retryDelay: Int, random: NakamaRandomGenerator) -> Int {
        return Int(Double(retryDelay) * random.next())
    }
}

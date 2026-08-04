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

/// Represents a single retry attempt.
public struct Retry: Sendable {
    /// The delay (milliseconds) in the request retry attributable to the exponential backoff algorithm.
    public let exponentialBackoff: Int

    /// The delay (milliseconds) in the request retry attributable to the jitter algorithm.
    public let jitterBackoff: Int

    public init(exponentialBackoff: Int, jitterBackoff: Int) {
        self.exponentialBackoff = exponentialBackoff
        self.jitterBackoff = jitterBackoff
    }
}

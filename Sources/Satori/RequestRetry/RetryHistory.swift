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

/// Represents a history of retry attempts.
public final class RetryHistory
{
    /// The configuration for retry behavior.
    var configuration: RetryConfiguration?
    
    /// An array containing individual retry attempts.
    var retries: [Retry]
    
    /// A seeded random number generator.
    var random: SatoriRandomGenerator
    
    /// Initializes a `RetryHistory` instance with a given token and retry configuration.
    ///
    /// Typically called with the Nakama authentication methods using the id or token as a seed for the `RNG`.
    /// - Parameters:
    ///   - token: The id or authentication token used to seed the random number generator.
    ///   - configuration: The configuration specifying retry behavior.
    public init(token: String, configuration: RetryConfiguration) {
        self.configuration = configuration
        self.retries = []
        self.random = SatoriRandomGenerator(seed: token)
    }
    
    /// A convenience initializer that creates a `RetryHistory` instance using an existing session.
    ///
    /// Typically called with other Nakama methods after obtaining an authentication token.
    ///  The auth token will be used as a seed for the random generator.
    ///
    /// - Parameters:
    ///   - session: The authenticated session providing the token.
    ///   - configuration: The configuration specifying retry behavior.
    public convenience init(session: Session, configuration: RetryConfiguration) {
        self.init(token: session.authToken, configuration: configuration)
    }
}

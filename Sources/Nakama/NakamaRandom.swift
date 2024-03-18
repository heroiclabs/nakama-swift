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

/// A protocol defining a random number generator.
protocol Random {
    /// Generates a random double in the range `(0.0, 1.0]`
    /// - Returns; A random double between 0.0 (inclusive) and 1.0 (exclusive).
    func next() -> Double
    
    /**
     Generates a random double within the specified range.
     - Parameter range: The half-open range within which the random number is generated. Lower bound is inclusive, and upper bound is exclusive.
     - Returns: A random double within the specified range.
     */
    func next(in range: Range<Double>) -> Double
}

/// A custom implementation of the `Random` protocol providing a random number generator with a seed.
public final class NakamaRandomGenerator: Random {
    private var seed: UInt64
    
    /**
     Initialize the instance with the given `seed`.
     - Parameter seed: A string used to seed the random number generator.
     */
    init(seed: String) {
        var hasher = Hasher()
        seed.hash(into: &hasher)
        let truncated = UInt32(truncatingIfNeeded: hasher.finalize())

        srand48(Int(truncated))
        self.seed = UInt64(truncated)
    }
    
    func next() -> Double {
        return drand48()
    }
    
    func next(in range: Range<Double>) -> Double {
        return range.lowerBound + ((range.upperBound - range.lowerBound) * drand48())
    }
    
}

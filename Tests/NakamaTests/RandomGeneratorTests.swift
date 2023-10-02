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

import XCTest
@testable import Nakama

final class RandomGeneratorTests: XCTestCase {
    var generator: NakamaRandomGenerator!
    var uuid = UUID().uuidString
    
    override func setUp() async throws {
        generator = NakamaRandomGenerator(seed: uuid)
    }
    
    override func tearDown() {
        generator = nil
    }
    
    func test_sameSeededSequenceShouldMatch() {
        var sequence = [Double]()
        
        for _ in 1...5 {
            sequence.append(generator.next(in: 0.0..<1.0))
        }
        
        let generator2 = NakamaRandomGenerator(seed: uuid)
        let repeated = (1...5).map { _ in
            generator2.next(in: 0.0..<1.0)
        }
        XCTAssertEqual(sequence, repeated)
    }
    
    func test_differentSeededSequenceShouldNotMatch() {
        var sequence1 = [Double]()
        
        for _ in 1...3 {
            sequence1.append(generator.next())
        }
        
        generator = NakamaRandomGenerator(seed: "test_id")
        let sequence2 = (1...3).map { _ in
            generator.next()
        }
        XCTAssertNotEqual(sequence1, sequence2)
    }
}

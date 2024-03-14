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

import XCTest
@testable
import Satori

final class SessionTests: XCTestCase {
    private let client = HttpClient(host: "127.0.0.1", port: 7450, apiKey: "apikey")
    
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func test_sessionRefresh() async throws {
        let session = try await client.authenticate(id: "285fb548-1c23-42c2-84b5-cd18c22d7053")
        
        do {
            let newSession = try await client.sessionRefresh(session: session)
            XCTAssertNotNil(newSession)
        } catch {
            debugPrint(error)
            XCTFail("Refresh request should succeed")
        }
        
    }
}

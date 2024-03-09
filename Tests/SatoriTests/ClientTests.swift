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

final class ClientTests: XCTestCase {
    private let client = HttpClient(host: "127.0.0.1", port: 7450, apiKey: "apiKey")

    override func setUp() async throws {
        
    }
    
    override func tearDown() async throws {
        
    }

    public func test_AuthenticateAndLogout() async throws {
        let session = try await client.authenticate(id: "285fb548-1c23-42c2-84b5-cd18c22d7053")
        try await client.authenticateLogout(session: session)
        do {
            let _ = try await client.getExperiments(session: session, names: [])
            XCTAssert(false, "Session should be invalidated")
        } catch {
            XCTAssert(true)
        }
    }

    public func test_GetExperiments() async throws {
        let session = try await client.authenticate(id: "285fb548-1c23-42c2-84b5-cd18c22d7053")
        let experiments = try await client.getAllExperiments(session: session)
        
        XCTAssertTrue(experiments.experiments?.count == 1)
    }

    public func test_GetFlags() async throws {
        let session = try await client.authenticate(id: "285fb548-1c23-42c2-84b5-cd18c22d7053")
        let flags = try await client.getFlags(session: session, names: [])
        XCTAssertTrue(flags.flags?.count == 4)
        
        let namedFlags = try await client.getFlags(session: session, names: ["Min-Build-Number"])
        XCTAssertTrue(namedFlags.flags?.count == 1)
    }

    public func test_SendEvents() async throws {
        let session = try await client.authenticate(id: "285fb548-1c23-42c2-84b5-cd18c22d7053")
        try await client.event(session: session, event: Event(name: "gameFinished", timestamp: Date(), metadata: ["score":"1000"]))
        try await client.events(session: session, events: [
            Event(name: "adStarted", timestamp: Date()),
            Event(name: "appLaunched", timestamp: Date())
        ])
    }

    public func test_GetLiveEvent() async throws {
        let session = try await client.authenticate(id: "285fb548-1c23-42c2-84b5-cd18c22d7053")
        let liveEvents = try await client.getLiveEvents(session: session)
        
        XCTAssertTrue(liveEvents.liveEvents == nil)
    }
}

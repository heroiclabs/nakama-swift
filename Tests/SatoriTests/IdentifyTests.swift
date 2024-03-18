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

final class IdentifyTests: XCTestCase {
    private let client = HttpClient(scheme: "http", host: "127.0.0.1", port: 7450, apiKey: "apikey")
    
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    func test_identifyEvents() async throws {
        let session1 = try await client.authenticate(id: "11111111-1111-0000-0000-000000000000")
        
        let props1 = ["email": "a@b.com", "pushTokenIos": "foo"]
        let customProps1 = ["earlyAccess": "true"]
        
        try await client.updateProperties(
            session: session1,
            defaultProperties: props1,
            customProperties: customProps1
        )
        
        let events = [
            Event(name: "awardReceived", timestamp: Date()),
            Event(name: "inventoryUpdated", timestamp: Date())
        ]
        try await client.events(session: session1, events: events)
        
        // Wait for 2 seconds
        sleep(2)
        
        let session2 = try await client.authenticate(id: "22222222-2222-0000-0000-000000000000")
        
        let props2 = ["email": "a@b.com", "pushTokenAndroid": "bar"]
        let customProps2 = ["earlyAccess": "false"]
        
        try await client.updateProperties(
            session: session2,
            defaultProperties: props2,
            customProperties: customProps2
        )
        
        sleep(2)
        
        let session = try await client.identify(
            session: session1,
            id: "22222222-2222-0000-0000-000000000000",
            defaultProperties: [:],
            customProperties: [:]
        )
        
        XCTAssertNotNil(session)
        XCTAssertEqual(session.identityId, "22222222-2222-0000-0000-000000000000")
        
        let props = try await client.listProperties(session: session)
        
        XCTAssertNotNil(props.default_)
        
        XCTAssertGreaterThan(props.default_!.count, 0)
        XCTAssertGreaterThan(props.custom!.count, 0)
        
        // Default properties
        XCTAssertFalse(props.default_!.isEmpty)
        for (key, value) in props.default_! {
            switch key {
            case "email":
                XCTAssertEqual(value, "a@b.com")
            case "pushTokenAndroid":
                XCTAssertEqual(value, "bar")
            case "pushTokenIos":
                XCTAssertEqual(value, "foo")
            default:
                break
            }
        }
        
        // Custom properties
        XCTAssertNotNil(props.custom)
        XCTAssertFalse(props.custom!.isEmpty)
        for (key, value) in props.custom! {
            switch key {
            case "earlyAccess":
                XCTAssertEqual(value, "false")
            default:
                break
            }
        }
    }
}

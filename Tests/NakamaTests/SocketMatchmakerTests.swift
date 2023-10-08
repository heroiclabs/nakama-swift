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

final class SocketMatchmakerTests: XCTestCase {
    let client = GrpcClient(serverKey: "defaultkey")
    var socket: WebSocketClient!
    var session: Session!
    
    override func setUp() async throws {
        session = try await client.authenticateCustom(id: UUID().uuidString)
        socket = client.createSocket() as? WebSocketClient
    }
    
    override func tearDown() async throws {
        socket.disconnect()
        try await client.disconnect()
    }
    
    func test_joinLeaveMatchmaker() async throws {
        socket.connect(session: session)
        let ticket = try await socket.addMatchmaker()
        XCTAssertNotNil(ticket)
        XCTAssertNotEqual(ticket.ticket, "")
        
        do {
            sleep(3)
            socket.onError = { error in
                dump(error)
            }
            try await socket.removeMatchmaker(ticket: ticket.ticket)
            sleep(1)
            XCTAssertTrue(true)
        } catch {
            XCTFail("Failed to leave matchmaker with error: \(error.localizedDescription)")
        }
    }
    
    func test_symmetricMatchmakerQueryAndSize() async throws {
        let session2 = try await client.authenticateCustom(id: UUID().uuidString)
        let session3 = try await client.authenticateCustom(id: UUID().uuidString)
        let socket2: WebSocketClient = client.createSocket() as! WebSocketClient
        let socket3: WebSocketClient = client.createSocket() as! WebSocketClient
        
        var matched1: Nakama_Realtime_MatchmakerMatched!
        socket.onMatchmakerMatched = { matched in
            matched1 = matched
        }
        var matched2: Nakama_Realtime_MatchmakerMatched!
        socket2.onMatchmakerMatched = { matched in
            matched2 = matched
        }
        var matched3: Nakama_Realtime_MatchmakerMatched!
        socket3.onMatchmakerMatched = { matched in
            matched3 = matched
        }
        
        socket.connect(session: session)
        socket2.connect(session: session2)
        socket3.connect(session: session3)
        
        let ticket1 = try await socket.addMatchmaker (query: "+properties.foo:bar", minCount: 3, maxCount: 3, stringProperties: ["foo":"bar"])
        let ticket2 = try await socket2.addMatchmaker(query: "+properties.foo:bar", minCount: 3, maxCount: 3, stringProperties: ["foo":"bar"])
        let ticket3 = try await socket3.addMatchmaker(query: "+properties.foo:bar", minCount: 3, maxCount: 3, stringProperties: ["foo":"bar"])
        
        sleep(15)
        
        XCTAssertNotNil(ticket1)
        XCTAssertNotEqual(ticket1.ticket, "")
        XCTAssertNotNil(ticket2)
        XCTAssertNotEqual(ticket2.ticket, "")
        XCTAssertNotNil(ticket3)
        XCTAssertNotEqual(ticket3.ticket, "")
        
        XCTAssertNotNil(matched1)
        XCTAssertNotEqual(matched1.ticket, "")
        XCTAssertNotNil(matched2)
        XCTAssertNotEqual(matched2.ticket, "")
        XCTAssertNotNil(matched3)
        XCTAssertNotEqual(matched3.ticket, "")
        
        XCTAssertEqual(matched1.token, matched2.token)
        XCTAssertEqual(matched2.token, matched3.token)
        XCTAssertEqual(matched1.token, matched3.token)
    }
}

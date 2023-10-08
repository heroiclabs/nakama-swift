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

final class SocketMatchTests: XCTestCase {
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
    
    func test_createLeaveMatchWithWithoutName() async throws {
        // With name
        socket.connect(session: session)
        let match = try await socket.createMatch(name: "test.match")
        XCTAssertNotNil(match)
        XCTAssertNotEqual(match.matchID, "")
        
        // Without name
        socket.connect(session: session)
        let match2 = try await socket.createMatch()
        XCTAssertNotNil(match2)
        XCTAssertNotEqual(match2.matchID, "")
        
        // Leave
        do {
            try await socket.leaveMatch(matchId: match.matchID)
            try await socket.leaveMatch(matchId: match2.matchID)
            XCTAssertTrue(true)
        } catch {
            XCTFail("Failed to leave match with error: \(error.localizedDescription)")
        }
    }
    
    func test_AnotherUserJoinMatch() async throws {
        let session2 = try await client.authenticateCustom(id: UUID().uuidString)
        let socket2: WebSocketClient = client.createSocket() as! WebSocketClient
        
        socket.connect(session: session)
        socket2.connect(session: session2)
        
        let match = try await socket.createMatch()
        XCTAssertNotNil(match)
        let match2 = try await socket2.joinMatch(matchId: match.matchID)
        XCTAssertNotNil(match2)
        
        XCTAssertEqual(match.matchID, match2.matchID)
        XCTAssertEqual(match.presences.count, 0)
        XCTAssertEqual(match.self_p.userID, session.userId)
        XCTAssertEqual(match2.presences.count, 1)
    }
    
    func test_sendMatchState() async throws {
        let session2 = try await client.authenticateCustom(id: UUID().uuidString)
        let socket2 = client.createSocket() as! WebSocketClient
        
        let dataToSend = "{\"hello\":\"world\"}"

        var receivedData: Nakama_Realtime_MatchData!
        socket2.onMatchData = { data in
            receivedData = data
        }
        socket.connect(session: session)
        socket2.connect(session: session2)
        
        let match = try await socket.createMatch()
        _ = try await socket2.joinMatch(matchId: match.matchID)
        try await socket.sendMatchData(matchId: match.matchID, opCode: 0, data: dataToSend)
        sleep(3)
        
        XCTAssertNotNil(receivedData)
        XCTAssertEqual(receivedData.matchID, match.matchID)
        XCTAssertEqual(receivedData.data, dataToSend.data(using: .utf8))
    }
    
    func test_twoPresencesReceivedForTwoUsers() async throws {
        let session2 = try await client.authenticateCustom(id: UUID().uuidString)
        let socket2 = client.createSocket() as! WebSocketClient
        
        socket.connect(session: session)
        socket2.connect(session: session2)
        
        var user1Presences = Set<String>()
        var user2Presences = Set<String>()
        
        socket.onMatchPresence = { presence in
            presence.joins.forEach { user1Presences.insert($0.userID) }
        }
        socket2.onMatchPresence = { presence in
            presence.joins.forEach { user2Presences.insert($0.userID) }
        }
        
        let match = try await socket.createMatch()
        let match2 = try await socket2.joinMatch(matchId: match.matchID)
        sleep(3)
        
        for presence in match2.presences {
            user2Presences.insert(presence.userID)
        }
        
        XCTAssertEqual(user1Presences.count, 2)
        XCTAssertEqual(user2Presences.count, 2)
        
        do {
            try await socket.leaveMatch(matchId: match.matchID)
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
}

/*
 * Copyright 2023 The Nakama Authors
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
import XCTest
@testable import Nakama

final class LeaderboardTests: XCTestCase {
    static var leaderboardId = ""
    
    let client = GrpcClient(serverKey: "defaultkey", trace: true)
    
    var session: Session!
    
    override func setUp() async throws {
        session = try await client.authenticateDevice(id: "285fb548-1c23-42c2-84b5-cd18c22d7053")
        
        // Initialize leaderboard once
        guard Self.leaderboardId.isEmpty else { return }
        
        let leaderboard = try await client.rpc(session: session, id: "clientrpc.create_leaderboard", payload: "{\"operator\":\"best\"}")
        
        if let id = leaderboard?.payload.jsonDictionary?["leaderboard_id"] as? String {
            Self.leaderboardId = id
        } else {
            XCTFail("Failed to parse leaderboard id")
        }
    }

    override func tearDown() async throws {
        try await client.disconnect()
        session = nil
    }

    func test01_writeLeaderboardRecord() async throws {
        let score = 1000
        let subScore = 50
        let metadata = "{\"country\": \"us\"}"
        let record = try await client.writeLeaderboardRecord(session: session, leaderboardId: Self.leaderboardId, score: score, subScore: subScore, metadata: metadata, leaderboardOperator: .best)
        XCTAssertNotNil(record)
        XCTAssertEqual(record.leaderboardId, Self.leaderboardId)
        XCTAssertEqual(record.ownerId, session.userId)
        XCTAssertEqual(record.score, score)
        XCTAssertEqual(record.subScore, subScore)
        XCTAssertEqual(record.metadata, metadata)
    }
    
    func test02_listLeaderboardRecords() async throws {
        // Write with a different owner
        let anotherSession = try await client.authenticateDevice(id: UUID().uuidString)
        let anotherRecord = try await client.writeLeaderboardRecord(session: anotherSession, leaderboardId: Self.leaderboardId, score: 50, subScore: 0, metadata: "", leaderboardOperator: .best)
        XCTAssertNotNil(anotherRecord)
        
        let records = try await client.listLeaderboardRecords(session: session, leaderboardId: Self.leaderboardId, ownerIds: [], expiry: nil, limit: 2, cursor: nil)
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records.nextCursor, "")
        XCTAssertEqual(records.prevCursor, "")
        XCTAssertEqual(records.records.count, 2)
    }
    
    func test03_listLeaderboardRecordsAroundOwner() async throws {
        let records = try await client.listLeaderboardRecordsAroundOwner(session: session, leaderboardId: Self.leaderboardId, ownerId: session.userId)
        XCTAssertNotNil(records)
        XCTAssertEqual(records.records.count, 1)
        XCTAssertEqual(records.records.first?.ownerId, session.userId)
    }
    
    func test04_deleteLeaderboardReccord() async throws {
        try await client.deleteLeaderboardRecord(session: session, leaderboardId: Self.leaderboardId)
        
        let records = try await client.listLeaderboardRecordsAroundOwner(session: session, leaderboardId: Self.leaderboardId, ownerId: session.userId)
        XCTAssertNotNil(records)
        XCTAssertEqual(records.records.count, 0)
    }
}

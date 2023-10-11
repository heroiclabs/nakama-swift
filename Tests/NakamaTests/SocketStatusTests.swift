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

final class SocketStatusTests: XCTestCase {
    let client = GrpcClient(serverKey: "defaultkey")
    var socket: Socket!
    var session: Session!
    
    override func setUp() async throws {
        session = try await client.authenticateCustom(id: UUID().uuidString)
        socket = client.createSocket() as? Socket
    }
    
    override func tearDown() async throws {
        socket.disconnect()
        try await client.disconnect()
    }
    
    func test_followUnfollowStopUpdates() async throws {
        let session2 = try await client.authenticateCustom(id: UUID().uuidString)
        let socket2 = client.createSocket() as! Socket
        
        var update: Nakama_Realtime_StatusPresenceEvent!
        
        socket.connect(session: session)
        socket2.connect(session: session2)
        socket.onStatusPresence = { presence in
            update = presence
        }
        let followStatus = try await socket.followUsers(userIds: [session2.userId])
        XCTAssertNotNil(followStatus)
        
        try await socket2.updateStatus(status: "New Status")
        sleep(1)
        
        XCTAssertEqual(update.joins.count, 1)
        
        // Unfollow and update status
        update = nil
        try await socket.unfollowUsers(userIds: [session2.userId])
        try await socket2.updateStatus(status: "Another status")
        sleep(1)
        
        XCTAssertNil(update) // No status update received
    }
    
    func test_followNonExistentUser() async throws {
        socket.connect(session: session)
        do {
            _ = try await socket.followUsers(userIds: [UUID().uuidString])
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func test_followTwiceUpdatesOnce() async throws {
        let session2 = try await client.authenticateCustom(id: UUID().uuidString)
        let socket2 = client.createSocket() as! Socket
        
        var updateCount = 0
        
        socket.connect(session: session)
        socket2.connect(session: session2)
        socket2.onStatusPresence = { _ in
            updateCount += 1
        }
        
        var status = try await socket.followUsers(userIds: [session2.userId])
        XCTAssertNotNil(status)
        status = try await socket.followUsers(userIds: [session2.userId])
        XCTAssertNotNil(status)
        try await socket2.updateStatus(status: "New status")
        sleep(1)
        
        XCTAssertEqual(updateCount, 1)
    }
    
    func test_unfollowSelfShouldKeepReceivedUpdates() async throws {
        var receivedUpdate = false
        socket.connect(session: session)
        socket.onStatusPresence = { _ in
            receivedUpdate = true
        }
        _ = try await socket.unfollowUsers(userIds: [session.userId])
        try await socket.updateStatus(status: "Unfollowing my self")
        sleep(1)
        
        XCTAssertTrue(receivedUpdate)
    }
}

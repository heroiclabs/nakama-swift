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

final class NotificationTest: XCTestCase {
    let client = GrpcClient(serverKey: "defaultkey")
    var session: Session!
    
    override func setUp() async throws {
        try await session = client.authenticateDevice(id: "defaultkey")
    }
    
    override func tearDown() async throws {
        session = nil
        try await client.disconnect()
    }
    
    func test01_listDeleteNotifications() async throws {
        let target = try await client.authenticateCustom(id: UUID().uuidString)
        // Send
        let rpc = try await client.rpc(session: session, id: "clientrpc.send_notification", payload: "{\"user_id\":\"\(target.userId)\"}")
        XCTAssertNotNil(rpc)
        
        // List
        var list = try await client.listNotifications(session: target, limit: 3)
        XCTAssertNotNil(list)
        XCTAssertEqual(list.notifications.count, 1)
        
        // Delete
        try await client.deleteNotifications(session: target, ids: list.notifications.map { $0.id })
        list = try await client.listNotifications(session: target)
        XCTAssertNotNil(list)
        XCTAssertEqual(list.notifications.count, 0)
    }
}

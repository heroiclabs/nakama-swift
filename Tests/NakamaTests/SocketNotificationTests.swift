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

final class SocketNotificationTests: XCTestCase {
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
    
    func test_receiveNotification() async throws {
        socket.connect(session: session)
        
        var notifications: Nakama_Realtime_Notifications!
        socket.onNotifications = { notifs in
            notifications = notifs
        }
        
        _ = try await socket.rpc(id: "clientrpc.send_notification", payload: "{\"user_id\":\"\(session.userId)\"}")
        sleep(3)
        
        XCTAssertNotNil(notifications)
        XCTAssertEqual(notifications.notifications.first?.senderID, session.userId)
    }
}

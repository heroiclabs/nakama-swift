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

/*
enum TimeoutError: Error {
    case timedOut
}

func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in 
        group.addTask {
            try await operation()
        }

        group.addTask {
            try await Task.sleep(for: .seconds(seconds))
            throw TimeoutError.timedOut
        }

        guard let result = try await group.next() else {
            throw TimeoutError.timedOut
        }

        group.cancelAll()

        return result
    }
}
*/

final class SocketNotificationTests: XCTestCase {
    let client = TestConfig.makeClient()
    var socket: Socket!
    var session: Session!
    
    override func setUp() async throws {
        print("Start setup")
        session = try await client.authenticateCustom(id: UUID().uuidString)
        socket = client.createSocket() as? Socket
    }
    
    override func tearDown() async throws {
        socket.disconnect()
        try await client.disconnect()
    }
    
    func test_receiveNotification() async throws {
        fputs("Start test", stderr)

        socket.connect(session: session)

        try await Task.sleep(for: .seconds(1))

        let expectation = XCTestExpectation(description: "Wait for notification")
        
        var notifications: Nakama_Realtime_Notifications!
        socket.onNotifications = { notifs in
            notifications = notifs
            expectation.fulfill()
        }
        
        do {
            _ = try await socket.rpc(
                id: "clientrpc.send_notification",
                payload: "{\"user_id\":\"\(session.userId)\"}"
            )
        }
        catch {
            XCTFail("RPC call failed: \(error).")
            return
        }

        let result = await XCTWaiter().fulfillment(of: [expectation], timeout: 4.0)

        XCTAssertEqual(result, .completed, "Notification callback timed out.")
        guard let notifications else {
            XCTFail("No notification was received.")
            return
        }
        XCTAssertEqual(notifications.notifications.first?.senderID, session.userId)
    }
}

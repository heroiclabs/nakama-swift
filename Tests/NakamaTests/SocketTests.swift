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

final class SocketTests: XCTestCase {
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
    
    func test_CreateConnectSocket() async throws {
        // Create
        XCTAssertNotNil(session)
        XCTAssertNotNil(socket)
        
        // Connect
        socket.connect(session: session)
        sleep(1)
        XCTAssertTrue(socket.isConnected)
        XCTAssertFalse(socket.isConnecting)
        
        socket.disconnect()
        
        _ = await XCTWaiter.fulfillment(of: [XCTestExpectation()], timeout: 1)
        
        XCTAssertFalse(socket.isConnected)
        XCTAssertFalse(socket.isConnecting)
    }
    
    func test_MultipleSocketConnects() async throws {
        XCTAssertNotNil(socket)
        
        socket.connect(session: session)
        sleep(1)
        XCTAssertTrue(socket.isConnected)
        XCTAssertFalse(socket.isConnecting)
        
        socket.connect(session: session)
        sleep(1)
        XCTAssertTrue(socket.isConnected)
        XCTAssertFalse(socket.isConnecting)
    }
    
    func test_disconnectBeforeConnect() async throws {
        socket.disconnect()
        sleep(1)
        socket.connect(session: session)
        sleep(1)
        
        XCTAssertTrue(socket.isConnected)
    }
    
    func test_longLivedSocketLifecycle() async throws {
        socket.connect(session: session)
        sleep(60)
        
        XCTAssertTrue(socket.isConnected)
        socket.disconnect()
    }
}

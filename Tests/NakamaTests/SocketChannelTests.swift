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

final class SocketChannelTests: XCTestCase {
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
    
    func test_createRoomChannel() async throws {
        socket.connect(session: session)
        
        let channel = try await socket.joinChat(target: "my.room", type: .room)
        XCTAssertNotNil(channel)
        XCTAssertNotNil(channel.id)
        XCTAssertEqual(channel.selfPresence.userId, session.userId)
        XCTAssertEqual(channel.selfPresence.username, session.username)
    }
    
    func test_sendMessageInRoomChannel() async throws {
        socket.connect(session: session)
        var message: Nakama_Api_ChannelMessage!
        socket.onChannelMessage = { msg in
            message = msg
        }
        
        let channel = try await socket.joinChat(target: "my.room", type: .room)
        XCTAssertNotNil(channel)
        
        let messageAck = try await socket.writeChatMessage(channelId: channel.id, content: "{\"hello\":\"world\"}")
        XCTAssertNotNil(messageAck)
        sleep(3)
        
        XCTAssertEqual(messageAck.channelID, message.channelID)
        XCTAssertEqual(messageAck.messageID, message.messageID)
        XCTAssertEqual(messageAck.username, message.username)
    }
    
    func test_sendMessageInDirectChannel() async throws {
        socket.connect(session: session)
        var message: Nakama_Api_ChannelMessage!
        socket.onChannelMessage = { msg in
            message = msg
        }
        
        let session2 = try await client.authenticateCustom(id: UUID().uuidString)
        let socket2 = client.createSocket() as! Socket
        
        // Add as friends
        try await client.addFriends(session: session, ids: [session2.userId])
        try await client.addFriends(session: session2, ids: [session.userId])
        
        socket.connect(session: session)
        socket2.connect(session: session2)
        sleep(1)
        
        let channel = try await socket.joinChat(target: session2.userId, type: .room)
        sleep(1)
        let ack = try await socket.writeChatMessage(channelId: channel.id, content: "{\"hello\":\"world\"}")
        XCTAssertNotNil(ack)
        XCTAssertEqual(ack.channelID, message.channelID)
        XCTAssertEqual(ack.messageID, message.messageID)
        XCTAssertEqual(ack.username, message.username)
    }
}


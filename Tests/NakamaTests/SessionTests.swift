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

import XCTest
import Foundation
import Logging
@testable import Nakama

final class SessionTests: XCTestCase {
    let logger = Logger(label: "nakama-test")
    let client = GrpcClient(serverKey: "defaultkey", trace: true)
    let vars = ["platform":"ios"]
    
    var session: Session!
    
    override func setUp() async throws {
        session = try await client.authenticateDevice(id: "285fb548-1c23-42c2-84b5-cd18c22d7053", create: nil, username: nil, vars: vars)
    }
    
    override func tearDown() async throws {
        try await client.disconnect()
        session = nil
    }
    
    func test01_AuthenticateDevice() {
        XCTAssertNotNil(session)
        XCTAssertFalse(session.expired)
        XCTAssertEqual(session.sessionVars, vars)
    }
    
    func test02_RefreshToken() async throws {
        let newVars = ["lang":"en"]
        let newSession = try await client.refreshSession(session: session, vars: newVars)
        XCTAssertNotNil(newSession)
        XCTAssertEqual(newSession.expired, false)
        XCTAssertEqual(newSession.sessionVars, newVars)
    }
    
    func test03_Logout() async throws {
        try await client.sessionLogout(session: session)
        do {
            _ = try await client.refreshSession(session: session, vars: [:])
            XCTFail("Session refresh from logged out session should not work!")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func test04_getAccount() async throws {
        let account = try await client.getAccount(session: session)
        XCTAssertNotNil(account)
        XCTAssertNotNil(account.user)
        XCTAssertNotNil(account.user.username)
        XCTAssertNotNil(account.user.createTime)
    }
    
    /*
    func testRealtimeChat() {
        let session1 = newSession()
        let session2 = newSession(id: "my-second-ios-device")
        var socket1 = client.createSocket(host: client.host, port: 7350, ssl: client.ssl)
        var socket2 = client.createSocket(host: client.host, port: 7350, ssl: client.ssl)
        socket1.onError = { error in
            self.logger.error("Socket 1 received error: \(error)")
        }
        socket2.onError = { error in
            self.logger.error("Socket 2 received error: \(error)")
        }
        socket1.onConnect = {
            self.logger.info("Socket 1 connected")
        }
        socket2.onConnect = {
            self.logger.info("Socket 2 connected")
        }
        socket1.onDisconnect = {
            self.logger.info("Socket 1 disconnected")
        }
        socket2.onDisconnect = {
            self.logger.info("Socket 2 disconnected")
        }
        socket1.onChannelMessage = { message in
            self.logger.info("Received message from \(message.channelID): \(message.content)")
        }
        socket2.onChannelMessage = { message in
            self.logger.info("Received message from \(message.channelID): \(message.content)")
        }
        
        socket1.connect(session: session1, createStatus: true)
        socket2.connect(session: session2, createStatus: true)
        let channel1 = try! socket1.joinChat(target: session2.userId, type: .directMessage, persistence: false, hidden: false).wait()
        let channel2 = try! socket2.joinChat(target: session1.userId, type: .directMessage, persistence: false, hidden: false).wait()
        
        XCTAssertNotEqual(channel1.id, "")
        XCTAssertNotEqual(channel2.id, "")
        XCTAssertNotEqual(channel2.presences, [])
        logger.info("Created new DM channel for users \(session1.username) and \(session2.username).")

        let jsonData = try! JSONSerialization.data(withJSONObject: ["hello":"this-is-a-message"])
        let jsonData2 = try! JSONSerialization.data(withJSONObject: ["hello":"this-is-a-second-message"])
        
        let ack1 = try! socket1.writeChatMessage(channelId: channel1.id, content: String(data: jsonData, encoding: String.Encoding.utf8)!).wait()
        let ack2 = try! socket2.writeChatMessage(channelId: channel2.id, content: String(data: jsonData2, encoding: String.Encoding.utf8)!).wait()
        
        XCTAssertNotEqual(ack1.messageID, "")
        XCTAssertNotEqual(ack2.messageID, "")        
        logger.info("Wrote two messages to the channels.")
        socket1.disconnect()
        socket2.disconnect()
        try! client.disconnect().wait()
    }*/
}

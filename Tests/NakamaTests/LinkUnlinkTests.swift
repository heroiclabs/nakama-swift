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

import GRPC
import XCTest
@testable import Nakama

class LinkUnlinkTests: XCTestCase {
    let client = GrpcClient(serverKey: "defaultkey")
    
    override func tearDown() async throws {
        try await client.disconnect()
    }
    
    func test_linkUnlinkCustomId() async throws {
        let deviceId = UUID().uuidString
        // Link
        let session = try await client.authenticateDevice(id: deviceId)
        let customId = UUID().uuidString
        try await client.linkCustom(session: session, id: customId)
        XCTAssertNotNil(session)
        XCTAssertEqual(session.userId, session.userId)
        XCTAssertEqual(session.username, session.username)
        
        // Unlink
        try await client.unlinkCustom(session: session, id: customId)
        let account = try await client.getAccount(session: session)
        XCTAssertNotNil(account)
        XCTAssertEqual(account.customId, "")
        XCTAssertEqual(account.devices.count, 1)
        XCTAssertEqual(account.devices.first?.id, deviceId)
    }
    
    func test_linkUnlinkDeviceId() async throws {
        let newDeviceId = UUID().uuidString
        // Link
        let session = try await client.authenticateDevice(id: UUID().uuidString)
        try await client.linkDevice(session: session, id: newDeviceId)
        XCTAssertNotNil(session)
        XCTAssertEqual(session.userId, session.userId)
        XCTAssertEqual(session.username, session.username)
        
        // Unlink
        try await client.unlinkDevice(session: session, id: newDeviceId)
        let account = try await client.getAccount(session: session)
        XCTAssertNotNil(account)
        XCTAssertEqual(account.devices.count, 1)
        XCTAssertNotEqual(account.devices.first?.id, newDeviceId)
    }
    
    func test_linkUnlinkEmail() async throws {
        // Link
        let session = try await client.authenticateCustom(id: UUID().uuidString)
        let email = "\(UUID().uuidString)@email.com"
        let password = "examplepassword"
        try await client.linkEmail(session: session, email: email, password: password)
        let linked = try await client.authenticateEmail(email: email, password: password)
        XCTAssertNotNil(linked)
        XCTAssertEqual(linked.userId, session.userId)
        XCTAssertEqual(linked.username, session.username)
        
        // Unlink
        do {
            try await client.unlinkEmail(session: session, email: email, password: password)
        } catch {
            debugPrint(error)
        }
        let account = try await client.getAccount(session: session)
        XCTAssertNotNil(account)
        XCTAssertNotEqual(account.email, email)
    }
    
    func test_linkUnlinkAppleShouldFail() async throws {
        // Link
        let session = try await client.authenticateCustom(id: UUID().uuidString)
        do {
            try await client.linkApple(session: session, token: "token")
        } catch {
            XCTAssertEqual((error as! GRPCStatus).code, .failedPrecondition)
        }
        
        // Unlink
        do {
            try await client.unlinkApple(session: session, token: "token")
        } catch {
            XCTAssertEqual((error as! GRPCStatus).code, .unauthenticated)
        }
    }
    
    func test_linkUnlinkGoogleShouldFail() async throws {
        let session = try await client.authenticateCustom(id: UUID().uuidString)
        // Link
        do {
            try await client.linkGoogle(session: session, token: "token")
        } catch {
            XCTAssertEqual((error as! GRPCStatus).code, .unauthenticated)
        }
        
        // Unlink
        do {
            try await client.unlinkGoogle(session: session, token: "token")
        } catch {
            XCTAssertEqual((error as! GRPCStatus).code, .unauthenticated)
        }
    }
    
    func test_linkUnlinkGameCenterShouldFail() async throws {
        let session = try await client.authenticateCustom(id: UUID().uuidString)
        // Link
        let bundleId = "a"
        let playerId = "b"
        let publicKeyUrl = "c"
        let salt = "d"
        let signature = "e"
        let timestamp = 1
        do {
            try await client.linkGameCenter(session: session, bundleId: bundleId, playerId: playerId, publicKeyUrl: publicKeyUrl, salt: salt, signature: signature, timestamp: timestamp)
        } catch {
            dump(error as! GRPCStatus)
            XCTAssertEqual((error as! GRPCStatus).code, .unauthenticated)
        }
        
        // Unlink
        do {
            try await client.unlinkGameCenter(session: session, bundleId: bundleId, playerId: playerId, publicKeyUrl: publicKeyUrl, salt: salt, signature: signature, timestamp: timestamp)
        } catch {
            dump(error as! GRPCStatus)
            XCTAssertEqual((error as! GRPCStatus).code, .unauthenticated)
        }
    }
    
    func test_linkUnlinkFacebookShouldFail() async throws {
        let session = try await client.authenticateCustom(id: UUID().uuidString)
        // Link
        do {
            try await client.linkFacebook(session: session, token: "token")
        } catch {
            XCTAssertEqual((error as! GRPCStatus).code, .unauthenticated)
        }
        
        // Unlink
        do {
            try await client.unlinkFacebook(session: session, token: "token")
        } catch {
            XCTAssertEqual((error as! GRPCStatus).code, .unauthenticated)
        }
    }
    
    func test_linkUnlinkSteamShouldFail() async throws {
        let session = try await client.authenticateCustom(id: UUID().uuidString)
        // Link
        do {
            try await client.linkSteam(session: session, token: "token", import: false)
        } catch {
            XCTAssertEqual((error as! GRPCStatus).code, .failedPrecondition)
        }
        
        // Unlink
        do {
            try await client.unlinkSteam(session: session, token: "token")
        } catch {
            XCTAssertEqual((error as! GRPCStatus).code, .unauthenticated)
        }
    }
}

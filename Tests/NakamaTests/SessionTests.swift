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
        XCTAssertFalse(session.isExpired)
        XCTAssertEqual(session.sessionVars, vars)
    }
    
    func test02_RefreshToken() async throws {
        let newVars = ["lang":"en"]
        let newSession = try await client.refreshSession(session: session, vars: newVars)
        XCTAssertNotNil(newSession)
        XCTAssertEqual(newSession.isExpired, false)
        XCTAssertEqual(newSession.sessionVars.contains { $0.key == newVars.first?.key }, true)
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
}

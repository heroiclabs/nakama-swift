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

final class GroupTests: XCTestCase {
    let client = GrpcClient(serverKey: "defaultkey", trace: true)
    
    var session: Session!
    
    override func setUp() async throws {
        session = try await client.authenticateDevice(id: "285fb548-1c23-42c2-84b5-cd18c22d7053")
    }
    
    override func tearDown() async throws {
        session = nil
        try await client.disconnect()
    }
    
    func test01_createGroupWithoutDuplication() async throws {
        let groupName = UUID().uuidString
        // New
        let group = try await client.createGroup(session: session, name: groupName)
        XCTAssertNotNil(group)
        XCTAssertNotNil(group.createTime)
        XCTAssertNotNil(group.updateTime)
        XCTAssertEqual(group.name, groupName)
        // Duplicate
        do {
            _ = try await client.createGroup(session: session, name: groupName)
            XCTFail("Creating duplicate groups not allowed")
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func test02_joinLeaveDeleteGroup() async throws {
        // Join
        let group = try await client.createGroup(session: session, name: UUID().uuidString)
        do {
            try await client.joinGroup(session: session, groupId: group.id)
            XCTAssertTrue(true)
        } catch {
            XCTFail(error.localizedDescription)
        }
        // Join non-existing
        do {
            try await client.joinGroup(session: session, groupId: "testtt")
            XCTFail("Must not join non existent group")
        } catch {
            XCTAssertTrue(true)
        }
        
        // Leave as superadmin
        do {
            try await client.leaveGroup(session: session, groupId: group.id)
            XCTFail("Cannot leave group as user is last superadmin")
        } catch {
            XCTAssertTrue(true)
        }
        // Leave non-existing
        do {
            try await client.leaveGroup(session: session, groupId: "")
            XCTFail("Must not leave non existent group")
        } catch {
            XCTAssertTrue(true)
        }
        
        // Delete
        do {
            try await client.deleteGroup(session: session, groupId: group.id)
            XCTAssertTrue(true)
        } catch {
            XCTFail(error.localizedDescription)
        }
        // Delete non-existing group
        do {
            try await client.deleteGroup(session: session, groupId: "")
            XCTFail("Must not delete non existent group")
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func test05_listGroups() async throws {
        _ = try await client.createGroup(session: session, name: UUID().uuidString)
        let groups = try await client.listGroups(session: session, name: nil, cursor: nil, langTag: nil, members: nil, open: nil)
        XCTAssertNotNil(groups)
        XCTAssertEqual(groups.groups.count, 1)
        XCTAssertNotNil(groups.groups[0].createTime)
        XCTAssertNotNil(groups.groups[0].updateTime)
    }
    
    func test06_listGroupsWithPagination() async throws {
        for _ in 1...10 {
            _ = try await client.createGroup(session: session, name: UUID().uuidString)
        }
        let groups = try await client.listGroups(session: session, limit: 9)
        XCTAssertNotNil(groups)
        XCTAssertEqual(groups.groups.count, 9)
        XCTAssertNotEqual(groups.cursor, "")
    }
    
    func test06_listGroupsWithNameFilter() async throws {
        let nameId = UUID().uuidString
        _ = try await client.createGroup(session: session, name: nameId)
        _ = try await client.createGroup(session: session, name: UUID().uuidString)
        
        let groups = try await client.listGroups(session: session, name: nameId, limit: 1)
        XCTAssertNotNil(groups)
        XCTAssertEqual(groups.groups.count, 1)
        XCTAssertEqual(groups.cursor, "")
    }
    
    func test07_listGroupsWithMembersFilter() async throws {
        let groupName = UUID().uuidString
        let firstGroup = try await client.createGroup(session: session, name: groupName, open: true) // Public group
        let secondGroup = try await client.createGroup(session: session, name: UUID().uuidString) // Private one
        XCTAssertNotNil(firstGroup)
        XCTAssertNotNil(secondGroup)
        
        let anotherSession = try await client.authenticateDevice(id: UUID().uuidString)
        try await client.joinGroup(session: anotherSession, groupId: firstGroup.id)
        
        let groups = try await client.listGroups(session: session, limit: 2, members: 2, open: true)
        XCTAssertNotNil(groups)
        XCTAssertEqual(groups.groups.count, 1)
        XCTAssertEqual(groups.groups[0].id, firstGroup.id)
        XCTAssertEqual(groups.cursor, "")
        
        // Clean up groups list for selective test runs
        try await client.deleteGroup(session: session, groupId: firstGroup.id)
        try await client.deleteGroup(session: session, groupId: secondGroup.id)
    }
}

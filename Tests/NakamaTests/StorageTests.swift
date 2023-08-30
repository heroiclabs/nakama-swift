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

import Foundation
import XCTest
@testable import Nakama

final class StorageTests: XCTestCase {
    let client: Client = GrpcClient(serverKey: "defaultkey", trace: true)
    
    var session: Session!
    
    override func setUp() async throws {
        session = try await client.authenticateDevice(id: "285fb548-1c23-42c2-84b5-cd18c22d7053")
    }
    
    override func tearDown() async throws {
        try await client.disconnect()
        session = nil
    }
    
    func test01_WriteStorageObject() async throws {
        let objects = [
            WriteStorageObject(
                collection: "stats",
                key: "skills",
                value: "{\"progress\":\"100\"}",
                version: "",
                readPermission: .ownerRead,
                writePermission: .ownerWrite
            )
        ]
        
        let storageAcks = try await client.writeStorageObjects(session: session, objects: objects)
        XCTAssertNotNil(storageAcks.acks.first)
    }
    
    func test02_ReadStorageObject() async throws {
        let ids = [
            StorageObjectId(collection: "stats", key: "skills", userId: session.userId),
        ]
        let readObjects = try await client.readStorageObjects(session: session, ids: ids)
        XCTAssertEqual(readObjects.count, ids.count)
    }
    
    func test03_deleteStorageObject() async throws {
        let ids = [
            StorageObjectId(collection: "stats", key: "skills", userId: session.userId)
        ]
        try await client.deleteStorageObjects(session: session, ids: ids)
        
        let reads = try await client.readStorageObjects(session: session, ids: ids)
        XCTAssertEqual(reads.count, 0)
    }
    
    func test04_listStorageObjectsWithPagination() async throws {
        // Write 20 objects to storage
        var testObjects = [WriteStorageObject]()
        for i in 1...20 {
            let obj = WriteStorageObject(
                collection: "stats",
                key: "skill \(i)",
                value: "{\"progress\":\"\(i)\"}",
                version: "",
                readPermission: .publicRead,
                writePermission: .ownerWrite
            )
            testObjects.append(obj)
        }
        _ = try await client.writeStorageObjects(session: session, objects: testObjects)
        // Fetch 10 elements
        let limit = 10
        let page1 = try await client.listStorageObjects(session: session, collection: "stats", limit: limit, cursor: "")
        XCTAssertEqual(page1.objects.count, limit)
        XCTAssertNotEqual(page1.cursor, "")
        // Fetch remaining 10 elements
        let page2 = try await client.listStorageObjects(session: session, collection: "stats", limit: limit, cursor: page1.cursor)
        XCTAssertEqual(page2.objects.count, 10)
        XCTAssertEqual(page2.cursor, "")
    }
}

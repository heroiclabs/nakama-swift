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

/// The read access permissions for the object.
public enum StorageReadPermission: Int {
    case noRead = 0
    case ownerRead = 1
    case publicRead = 2
}

/// The write access permissions for the object.
public enum StorageWritePermission: Int {
    case noWrite = 0
    case ownerWrite = 1
}

/// The object to store.
public struct WriteStorageObject {
    var collection: String
    var key: String
    var value: String
    var version: String
    var readPermission: StorageReadPermission
    var writePermission: StorageWritePermission
}

/// An identifier for a storage object.
public struct StorageObjectId {
    var collection: String
    var key: String
    var userId: String
    var version: String
    
    public init(collection: String, key: String, userId: String, version: String = "") {
        self.collection = collection
        self.key = key
        self.userId = userId
        self.version = version
    }
}

/// A storage engine object.
public struct StorageObject {
    let collection: String
    let userID: String
    let key: String
    let value: String
    let version: String
    let permissionRead: StorageReadPermission
    let permissionWrite: StorageWritePermission
}

/// List of storage objects.
public struct StorageObjectList {
    /// The cursor for the next page of results, if any.
    let cursor: String
    
    /// The list of storage objects.
    let objects: [StorageObject]
    
    init(cursor: String, objects: [StorageObject]) {
        self.cursor = cursor
        self.objects = objects
    }
}

/// A storage acknowledgement.
public struct StorageObjectAck {
    let collection: String
    let key: String
    let userId: String
    let version: String
}

/// Batch of acknowledgements for the storage object write.
public struct StorageObjectAcks {
    let acks: [StorageObjectAck]
}

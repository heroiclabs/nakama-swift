/*
 * Copyright 2017 Heroic Labs
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

public struct StorageOp {
  fileprivate var payload = Server_TStorageUpdate.StorageUpdate.UpdateOp()
  
  public init(add path: String, value: Data) {
    payload.op = Int32(Server_TStorageUpdate.StorageUpdate.UpdateOp.UpdateOpCode.add.rawValue)
    payload.path = path
    payload.value = value
  }
  
  public init(append path: String, value: Data) {
    payload.op = Int32(Server_TStorageUpdate.StorageUpdate.UpdateOp.UpdateOpCode.append.rawValue)
    payload.path = path
    payload.value = value
  }
  
  public init(copy path: String, from: String) {
    payload.op = Int32(Server_TStorageUpdate.StorageUpdate.UpdateOp.UpdateOpCode.copy.rawValue)
    payload.path = path
    payload.from = from
  }
  
  public init(incr path: String, value: Int) {
    payload.op = Int32(Server_TStorageUpdate.StorageUpdate.UpdateOp.UpdateOpCode.incr.rawValue)
    payload.path = path
    
    var v = value
    payload.value = Data(bytes: &v, count: MemoryLayout.size(ofValue: v))
  }
  
  public init(init_ path: String, value: Data) {
    payload.op = Int32(Server_TStorageUpdate.StorageUpdate.UpdateOp.UpdateOpCode.init_.rawValue)
    payload.path = path
    payload.value = value
  }
  
  public init(merge path: String, value: Data) {
    payload.op = Int32(Server_TStorageUpdate.StorageUpdate.UpdateOp.UpdateOpCode.merge.rawValue)
    payload.path = path
    payload.value = value
  }
  
  public init(move path: String, from: String) {
    payload.op = Int32(Server_TStorageUpdate.StorageUpdate.UpdateOp.UpdateOpCode.move.rawValue)
    payload.path = path
    payload.from = from
  }
  
  public init(remove path: String) {
    payload.op = Int32(Server_TStorageUpdate.StorageUpdate.UpdateOp.UpdateOpCode.remove.rawValue)
    payload.path = path
  }
  
  public init(replace path: String, value: Data) {
    payload.op = Int32(Server_TStorageUpdate.StorageUpdate.UpdateOp.UpdateOpCode.replace.rawValue)
    payload.path = path
    payload.value = value
  }
  
  public init(test path: String, value: Data) {
    payload.op = Int32(Server_TStorageUpdate.StorageUpdate.UpdateOp.UpdateOpCode.test.rawValue)
    payload.path = path
    payload.value = value
  }
  
  public init(compare path: String, value: Data, assertValue: Int) {
    payload.op = Int32(Server_TStorageUpdate.StorageUpdate.UpdateOp.UpdateOpCode.compare.rawValue)
    payload.path = path
    payload.value = value
    payload.assert = Int64(assertValue)
  }
  
}

public struct StorageUpdateMessage : CollatedMessage {
  private var payload = Server_TStorageUpdate()
  
  public init() {
    payload.updates = []
  }
  
  public mutating func update(bucket: String, collection: String, key: String, ops: [StorageOp], version: Data?=nil, readPermission: PermissionRead?=nil, writePermission: PermissionWrite?=nil) {
    var update = Server_TStorageUpdate.StorageUpdate()
    
    if readPermission != nil {
      update.permissionRead = readPermission!.rawValue
    }
    
    if writePermission != nil {
      update.permissionWrite = writePermission!.rawValue
    }
    
    update.key = Server_TStorageUpdate.StorageUpdate.StorageKey()
    update.key.bucket = bucket
    update.key.collection = collection
    update.key.record = key
    
    if version != nil {
      update.key.version = version!
    }
    
    update.ops = []
    for op in ops {
      update.ops.append(op.payload)
    }
    
    payload.updates.append(update)
  }
  
  public func serialize(collationID: String) -> Data? {
    var envelope = Server_Envelope()
    envelope.storageUpdate = payload
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "StorageUpdateMessage(updates=%@)", payload.updates)
  }
  
}

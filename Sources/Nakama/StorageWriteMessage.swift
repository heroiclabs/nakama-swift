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

public struct StorageWriteMessage : CollatedMessage {
  private var payload = Server_TStorageWrite()
  
  public init() {
    payload.data = []
  }
  
  public mutating func write(bucket: String, collection: String, key: String, value: Data, version: Data?=nil, readPermission: PermissionRead?=nil, writePermission: PermissionWrite?=nil) {
    var data = Server_TStorageWrite.StorageData()
    data.bucket = bucket
    data.collection = collection
    data.record = key
    data.value = value
    
    if version != nil {
      data.version = version!
    }
    
    if readPermission != nil {
      data.permissionRead = readPermission!.rawValue
    } else {
      data.permissionRead = PermissionRead.ownerRead.rawValue
    }
    
    if writePermission != nil {
      data.permissionWrite = writePermission!.rawValue
    } else {
      data.permissionWrite = PermissionWrite.ownerWrite.rawValue
    }
    
    payload.data.append(data)
  }
  
  public func serialize(collationID: String) -> Data? {
    var envelope = Server_Envelope()
    envelope.storageWrite = payload
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "StorageWriteMessage(data=%@)", payload.data)
  }
  
}

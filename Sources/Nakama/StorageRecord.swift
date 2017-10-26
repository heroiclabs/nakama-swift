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

public enum PermissionRead : Int32 {
  case unknown = -1
  case noRead = 0
  case ownerRead = 1
  case publicRead = 2
  
  internal static func make(from code:Int32) -> PermissionRead {
    switch code {
    case 0:
      return .noRead
    case 1:
      return .ownerRead
    case 2:
      return .publicRead
    default:
      return .unknown
    }
  }
}

public enum PermissionWrite : Int32 {
  case unknown = -1
  case noWrite = 0
  case ownerWrite = 1
  
  internal static func make(from code:Int32) -> PermissionWrite {
    switch code {
    case 0:
      return .noWrite
    case 1:
      return .ownerWrite
    default:
      return .unknown
    }
  }
}

/**
 The composite identifier which represents a record from the storage engine.
 */
public protocol StorageRecord : StorageRecordID {
  /**
   - UTC timestamp when the record was created.
   */
  var createdAt : Int { get }
  
  /**
   - UTC timestamp when the record will expire.
   */
  var expiresAt : Int { get }
  
  /**
   - The read permission for the record.
   */
  var permissionRead : PermissionRead { get }
  
  /**
   - The write permission for the record.
   */
  var permissionWrite : PermissionWrite { get }
  
  /**
   - The value (content) of the record.
   */
  var value : Data { get }
  
  /**
   - UTC timestamp when the record was updated.
   */
  var updatedAt : Int { get }
  
  /**
   - The ID of the user who owns the record.
   */
  var userID : UUID { get }
}

internal struct DefaultStorageRecord : StorageRecord {
  let bucket: String
  let collection : String
  let key : String
  let version : Data
  let createdAt : Int
  let expiresAt : Int
  let permissionRead : PermissionRead
  let permissionWrite : PermissionWrite
  let value : Data
  let updatedAt : Int
  let userID : UUID
  
  internal init(from proto: Server_TStorageData.StorageData) {
    bucket = proto.bucket
    collection = proto.collection
    key = proto.record
    version = proto.version
    createdAt = Int(proto.createdAt)
    expiresAt = Int(proto.expiresAt)
    permissionRead = PermissionRead.make(from: proto.permissionRead)
    permissionWrite = PermissionWrite.make(from: proto.permissionWrite)
    value = proto.value
    updatedAt = Int(proto.updatedAt)
    
    userID = NakamaId.convert(data: proto.userID)
  }
  
  public var description: String {
    return String(format: "DefaultStorageRecord(bucket=%@,collection=%d,key=%@,version=%@,createdAt=%d,expiresAt=%d,permissionRead=%@,permissionWrite=%@,value=%@,updatedAt=%d,userId=%@)", bucket, collection, key, version.base64EncodedString(), createdAt, expiresAt, permissionRead.rawValue, permissionWrite.rawValue, value.base64EncodedString(), updatedAt, userID.uuidString)
  }
}

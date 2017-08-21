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

/**
  The composite identifier which represents a record from the storage engine.
 */
public protocol StorageRecordID : CustomStringConvertible {
  /**
   - Returns: The bucket (namespace) for the collections of records.
   */
  var bucket : String { get }
  
  /**
   - Returns: The collection the record belongs within.
   */
  var collection : String { get }
  
  /**
   - Returns: The key of the record.
   */
  var key : String { get }
  
  /**
   - Returns: The version of the record which has been fetched.
   */
  var version : Data { get }
}

internal struct DefaultStorageRecordID : StorageRecordID {
  let bucket: String
  let collection : String
  let key : String
  let version : Data
  
  internal init(from proto: Server_TStorageKeys.StorageKey) {
    bucket = proto.bucket
    collection = proto.collection
    key = proto.record
    version = proto.version
  }
  
  public var description: String {
    return String(format: "DefaultStorageRecordID(bucket=%@,collection=%d,key=%@,version=%@)", bucket, collection, key, version.base64EncodedString())
  }
}

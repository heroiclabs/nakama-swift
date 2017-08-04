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

public struct StorageFetchMessage : CollatedMessage {
  private var payload = Server_TStorageFetch()
  
  public init(){
    payload.keys = []
  }
  
  public mutating func fetch(bucket: String, collection: String, key: String, userID: UUID?=nil) {
    var record = Server_TStorageFetch.StorageKey()
    record.bucket = bucket
    record.collection = collection
    record.record = key
    if userID != nil {
      var id = userID!
      record.userID = withUnsafePointer(to: &id) {
        Data(bytes: $0, count: MemoryLayout.size(ofValue: id))
      }
    }
    
    payload.keys.append(record)
  }
    
  public func serialize(collationID: String) -> Data? {
    var envelope = Server_Envelope()
    envelope.storageFetch = payload
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "StorageFetchMessage(keys=%@)", payload.keys)
  }
  
}

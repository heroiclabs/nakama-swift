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

public struct StorageListMessage : CollatedMessage {
  public var userID : UUID?
  public var bucket: String?
  public var collection: String?
  public var limit: Int?
  public var cursor: Data?
  
  public init(bucket: String){
    self.bucket = bucket
  }
  
  public init(userID: UUID) {
    self.userID = userID
  }
  
  public func serialize(collationID: String) -> Data? {
    var listing = Server_TStorageList()
    
    if let id = userID {
      listing.userID = NakamaId.convert(uuid: id)
    }
    
    if bucket != nil {
      listing.bucket = bucket!
    }
    
    if let _collection = collection {
      listing.collection = _collection
    }
    
    if let _limit = limit {
      listing.limit = Int64(_limit)
    }
    
    if let _cursor = cursor {
      listing.cursor = _cursor
    }
    
    var envelope = Server_Envelope()
    envelope.storageList = listing
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "StorageListMessage(bucket=%@,collection=%@,userID=%@,limit=%d,cursor=%@)", bucket ?? "", collection ?? "", userID?.uuidString ?? "", limit ?? "", cursor?.base64EncodedString() ?? "nil")
  }
  
}

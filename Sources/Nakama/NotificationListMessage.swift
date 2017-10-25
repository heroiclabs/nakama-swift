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

public struct NotificationListMessage : CollatedMessage {
  public var cursor: Data?
  public var limit : Int
  
  public init(limit: Int){
    self.limit = limit
  }
  
  public func serialize(collationID: String) -> Data? {
    var listing = Server_TNotificationsList()
    listing.limit = Int64(limit)
    if let _cursor = cursor {
      listing.resumableCursor = _cursor
    }
    
    var envelope = Server_Envelope()
    envelope.notificationsList = listing
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "NotificationListMessage(limit=%d,cursor=%@)", limit, cursor?.base64EncodedString() ?? "nil")
  }
  
}


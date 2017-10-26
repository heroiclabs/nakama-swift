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

public struct TopicMessagesListMessage : CollatedMessage {
  private var userID: UUID?
  private var room: Data?
  private var groupID: Data?
  
  public var cursor: Data?
  public var forward: Bool?
  public var limit : Int?
  
  public init(userID: UUID){
    self.userID = userID
  }
  
  public init(room: Data){
    self.room = room
  }
  
  public init(groupID: Data){
    self.groupID = groupID
  }
  
  public func serialize(collationID: String) -> Data? {
    var listing = Server_TTopicMessagesList()

    if let _cursor = cursor {
      listing.cursor = _cursor
    }
    if let _forward = forward {
      listing.forward = _forward
    }
    if let _limit = limit {
      listing.limit = Int64(_limit)
    }
    
    if var _userID = userID {
      let uid = withUnsafePointer(to: &_userID) {
        Data(bytes: $0, count: MemoryLayout.size(ofValue: _userID))
      }
      listing.userID = uid
    }
    if let _room = room {
      listing.room = _room
    }
    if let _groupID = groupID {
      listing.groupID = _groupID
    }
    
    var envelope = Server_Envelope()
    envelope.topicMessagesList = listing
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "NotificationListMessage(userID=%@,room=%@,groupID=%@,forward=%@,limit=%d,cursor=%@)", userID?.uuidString ?? "", room?.base64EncodedString() ?? "", groupID?.base64EncodedString() ?? "", forward?.description ?? "unset", limit ?? 0, cursor?.base64EncodedString() ?? "nil")
  }
}

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
  public var topicId: TopicId
  public var cursor: Data?
  public var forward: Bool?
  public var limit : Int?
  
  public init(topicId: TopicId){
    self.topicId = topicId
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
    
    switch topicId {
    case .directMessage(let d):
      listing.userID = d
    case .group(let d):
      listing.groupID = d
    case .room(let d):
      listing.room = d
    }
    
    var envelope = Server_Envelope()
    envelope.topicMessagesList = listing
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "NotificationListMessage(topicId=%@,forward=%@,limit=%d,cursor=%@)", topicId.description, forward?.description ?? "unset", limit ?? 0, cursor?.base64EncodedString() ?? "nil")
  }
}

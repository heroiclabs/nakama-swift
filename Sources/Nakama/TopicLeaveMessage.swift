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

public struct TopicLeaveMessage : CollatedMessage {
  
  /**
   NOTE: The server only processes the first item of the list, and will ignore and logs a warning message for other items.
   */
  public var topics: [TopicId] = []
  
  public init(){}
  
  public func serialize(collationID: String) -> Data? {
    var proto = Server_TTopicsLeave()
    
    for topic in topics {
      var t = Server_TopicId()

      switch topic {
      case .directMessage(let d):
        t.dm = d
      case .group(let d):
        t.groupID = NakamaId.convert(uuid: d)
      case .room(let d):
        t.room = d.data(using: String.Encoding.utf8)!
      }

      proto.topics.append(t)
    }
    
    var envelope = Server_Envelope()
    envelope.topicsLeave = proto
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "TopicLeaveMessage(topics=%@)", topics)
  }
}


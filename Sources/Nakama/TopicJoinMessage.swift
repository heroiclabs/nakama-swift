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

public struct TopicJoinMessage : CollatedMessage {
  public var rooms: [Data] = []
  public var groups: [Data] = []
  public var directMessages: [Data] = []
  
  public init(){}
  
  public func serialize(collationID: String) -> Data? {
    var proto = Server_TTopicsJoin()
    
    for id in rooms {
      var join = Server_TTopicsJoin.TopicJoin()
      join.room = id
      proto.joins.append(join)
    }
    
    for id in groups {
      var join = Server_TTopicsJoin.TopicJoin()
      join.groupID = id
      proto.joins.append(join)
    }
    
    for id in directMessages {
      var join = Server_TTopicsJoin.TopicJoin()
      join.userID = id
      proto.joins.append(join)
    }
    
    var envelope = Server_Envelope()
    envelope.topicsJoin = proto
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "TopicJoinMessage(rooms=%@, groups=%@, directMessages=%@)", rooms, groups, directMessages)
  }
}

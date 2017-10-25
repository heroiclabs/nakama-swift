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

public enum TopicType : Int32 {
  case directMessage = 0
  case room = 1
  case group = 2
}

public protocol TopicId : CustomStringConvertible {
  var id : Data { get }
  var topicType : TopicType { get }
}

internal struct DefaultTopicId : TopicId {
  let id : Data
  let topicType : TopicType
  
  internal init(from proto: Server_TopicId) {
    switch proto.id! {
    case .dm(let data):
      topicType = TopicType.directMessage
      id = data
    case .room(let data):
      topicType = TopicType.room
      id = data
    case .groupID(let data):
      topicType = TopicType.group
      id = data
    }
  }
  
  public var description: String {
    return String(format: "DefaultTopicId(id=%@,topicType=%@", id.base64EncodedString(), topicType.rawValue)
  }
}

public protocol Topic : CustomStringConvertible {
  var topicId : TopicId { get }
  var presences : [UserPresence] { get }
  var presenceSelf : UserPresence { get }
}

internal struct DefaultTopic : Topic {
  let topicId : TopicId
  let presences : [UserPresence]
  let presenceSelf : UserPresence
  
  internal init(from proto: Server_TTopics.Topic) {
    topicId = DefaultTopicId(from: proto.topic)
    presenceSelf = DefaultUserPresence(from: proto.self_p)
    
    var ps : [UserPresence] = []
    for p in proto.presences {
      ps.append(DefaultUserPresence(from: p))
    }
    
    presences = ps
  }
  
  public var description: String {
    return String(format: "DefaultTopic(topicId=%@,presences=%@,presenceSelf=%@)", topicId.description, presences.description, presenceSelf.description)
  }
}


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

public enum TopicId : CustomStringConvertible {
  /**
   Direct message between two users
   */
  case directMessage(Data)
  
  /**
   Message in a dynamic room
   */
  case room(String)
  
  /**
   Message in a group chat
   */
  case group(UUID)
  
  internal static func make(from proto: Server_TopicId) -> TopicId {
    switch proto.id! {
    case .dm(let data):
      return .directMessage(data)
    case .room(let data):
      return .room(String.init(data: data, encoding: String.Encoding.utf8)!)
    case .groupID(let data):
      return .group(NakamaId.convert(data: data))
    }
  }
  
  public var description: String {
    switch self {
    case .directMessage(let d):
      return String(format: "TopicId(type=%@,id=%@)", "directMessage", d.base64EncodedString())
    case .group(let d):
      return String(format: "TopicId(type=%@,id=%@)", "group", d.uuidString)
    case .room(let d):
      return String(format: "TopicId(type=%@,id=%@)", "room", d)
    }
  }
}

public protocol Topic : CustomStringConvertible {
  /**
   Identifier for this topic
   */
  var topicId : TopicId { get }
  /**
   List of user presences in this topic
   */
  var presences : [UserPresence] { get }
  /**
   The current user's presence in the topic
   */
  var presenceSelf : UserPresence { get }
}

internal struct DefaultTopic : Topic {
  let topicId : TopicId
  let presences : [UserPresence]
  let presenceSelf : UserPresence
  
  internal init(from proto: Server_TTopics.Topic) {
    topicId = TopicId.make(from: proto.topic)
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


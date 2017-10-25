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

public protocol UserPresence : CustomStringConvertible {
  var userID : UUID { get }
  var sessionID : UUID { get }
  var handle : String { get }
}

internal struct DefaultUserPresence : UserPresence {
  let userID : UUID
  let sessionID : UUID
  let handle : String
  
  internal init(from proto: Server_UserPresence) {
    handle = proto.handle
    
    userID = proto.userID.withUnsafeBytes { bytes in
      return NSUUID.init(uuidBytes: bytes) as UUID
    }
    
    sessionID = proto.sessionID.withUnsafeBytes { bytes in
      return NSUUID.init(uuidBytes: bytes) as UUID
    }
  }
  
  public var description: String {
    return String(format: "DefaultUserPresence(userID=%@,sessionID=%@,handle=%@)", userID.uuidString, sessionID.uuidString, handle)
  }
}

public protocol TopicPresence : CustomStringConvertible {
  var topic : TopicId { get }
  var join : [UserPresence] { get }
  var leave : [UserPresence] { get }
}

internal struct DefaultTopicPresence : TopicPresence {
  let topic : TopicId
  let join : [UserPresence]
  let leave : [UserPresence]
  
  internal init(from proto: Server_TTopics.Topic) {
    topic = DefaultTopicId(from: proto.topic)
    
    var js : [UserPresence] = []
    for p in proto.presences {
      js.append(DefaultUserPresence(from: p))
    }
    join = js
    
    var ls : [UserPresence] = []
    for p in proto.presences {
      ls.append(DefaultUserPresence(from: p))
    }
    leave = ls
  }
  
  public var description: String {
    return String(format: "DefaultTopicPresence(topic=%@,join=%@,leave=%@)", topic.description, join.description, leave.description)
  }
}
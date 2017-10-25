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

public enum TopicMessageType : Int32 {
  case unknown = -1
  case chat = 0
  case groupJoin = 1
  case groupAdd = 2
  case groupLeave = 3
  case groupKick = 4
  case groupPromoted = 5
  
  internal static func make(from code:Int64) -> TopicMessageType {
    switch code {
    case 0:
      return .chat
    case 1:
      return .groupJoin
    case 2:
      return .groupAdd
    case 3:
      return .groupLeave
    case 4:
      return .groupKick
    case 5:
      return .groupPromoted
    default:
      return .unknown
    }
  }
}

public protocol TopicMessage : CustomStringConvertible {
  var topic : TopicId { get }
  var userID : UUID { get }
  var messageID : UUID { get }
  var createdAt : Int { get }
  var expiresAt : Int { get }
  var handle : String { get }
  var type : TopicMessageType { get }
  var data : Data { get }
}

internal struct DefaultTopicMessage : TopicMessage {
  let topic : TopicId
  let userID : UUID
  let messageID : UUID
  let createdAt : Int
  let expiresAt : Int
  let handle : String
  let type : TopicMessageType
  let data : Data
  
  internal init(from proto: Server_TopicMessage) {
    topic = DefaultTopicId(from: proto.topic)
    handle = proto.handle
    data = proto.data
    createdAt = Int(proto.createdAt)
    expiresAt = Int(proto.expiresAt)
    
    type = TopicMessageType.make(from: proto.type)
    
    userID = proto.userID.withUnsafeBytes { bytes in
      return NSUUID.init(uuidBytes: bytes) as UUID
    }
    messageID = proto.messageID.withUnsafeBytes { bytes in
      return NSUUID.init(uuidBytes: bytes) as UUID
    }
  }
  
  public var description: String {
    return String(format: "DefaultTopicMessage(topic=%@,userID=%@,messageID=%@,createdAt=%d,expiresAt=%d,handle=%@,type=%@,data=%@)", topic.description, userID.uuidString, messageID.uuidString, createdAt, expiresAt, handle, type.rawValue, data.base64EncodedString())
  }
}

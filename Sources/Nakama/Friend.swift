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

public enum FriendState : Int32 {
  case unknown = -1
  case mutualFriends = 0
  case invite = 1
  case invited = 2
  case blocked = 3
  
  internal static func make(from code:Int64) -> FriendState {
    switch code {
    case 0:
      return .mutualFriends
    case 1:
      return .invite
    case 2:
      return .invited
    case 3:
      return .blocked
    default:
      return .unknown
    }
  }
}

public protocol Friend : User {
  /**
   - The state of this relationship
   */
  var state : FriendState { get }
}

internal struct DefaultFriend : Friend {
  let avatarURL: String
  let createdAt : Int
  let fullname : String
  let handle : String
  let id : UUID
  let lang : String
  let lastOnlineAt : Int
  let location : String
  let metadata : Data
  let timezone : String
  let updatedAt : Int
  let state : FriendState
  
  internal init(from proto: Server_Friend) {
    avatarURL = proto.user.avatarURL
    createdAt = Int(proto.user.createdAt)
    fullname = proto.user.fullname
    handle = proto.user.handle
    lang = proto.user.lang
    lastOnlineAt = Int(proto.user.lastOnlineAt)
    location = proto.user.location
    metadata = proto.user.metadata
    timezone = proto.user.timezone
    updatedAt = Int(proto.user.updatedAt)
    
    id = proto.user.id.withUnsafeBytes { bytes in
      return NSUUID.init(uuidBytes: bytes) as UUID
    }
    
    state = FriendState.make(from: proto.state)
  }
  
  public var description: String {
    return String(format: "DefaultFriend(avatarURL=%@,createdAt=%d,fullname=%@,handle=%@,id=%@,lang=%@,lastOnlineAt=%d,location=%@,metadata=%@,timezone=%@,updatedAt=%d,state=%@)", avatarURL, createdAt, fullname, handle, id.uuidString, lang, lastOnlineAt, location, metadata.base64EncodedString(), timezone, updatedAt, state.rawValue)
  }
}

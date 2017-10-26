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

public enum GroupState : Int32 {
  case unknown = -1
  
  /**
   The user has admin rights
   */
  case admin = 0
  
  /**
   The user is a regular member of the group
   */
  case member = 1
  
  /**
   The user has requested to join the group
   */
  case join = 2
  
  internal static func make(from code:Int64) -> GroupState {
    switch code {
    case 0:
      return .admin
    case 1:
      return .member
    case 2:
      return .join
    default:
      return .unknown
    }
  }
}

public protocol Group : CustomStringConvertible {
  
  /**
   The ID of the group
   */
  var id : UUID { get }
  
  /**
   Whether this is a private group or not
   */
  var privateState : Bool { get }
  
  /**
   The user ID of the creator of the group.
   */
  var creatorID : UUID { get }
  
  /**
   The name of the group
   */
  var name : String { get }
  
  /**
   The description of the group
   */
  var desc : String { get }
  
  /**
   The URL to the avatar of the group
   */
  var avatarURL : String { get }
  
  /**
   The language of the group
   */
  var lang : String { get }
  
  /**
   Any metadata associated with the group.
   */
  var metadata : Data { get }
  
  /**
   Number of admins/members in the group
   */
  var count : Int { get }
  
  /**
   Unix timestamp of when the group was created
   */
  var createdAt : Int { get }
  
  /**
   Unix timestamp of when the group was last updated
   */
  var updatedAt : Int { get }
}

internal struct DefaultGroup : Group {
  let id : UUID
  let privateState : Bool
  let creatorID : UUID
  let name : String
  let desc : String
  let avatarURL : String
  let lang : String
  let metadata : Data
  let count : Int
  let createdAt : Int
  let updatedAt : Int
  
  internal init(from proto: Server_Group) {
    name = proto.name
    desc = proto.description_p
    avatarURL = proto.avatarURL
    lang = proto.lang
    metadata = proto.metadata
    count = Int(proto.count)
    createdAt = Int(proto.createdAt)
    updatedAt = Int(proto.updatedAt)
    privateState = proto.private
    
    id = NakamaId.convert(data: proto.id)
    creatorID = NakamaId.convert(data: proto.creatorID)
  }
  
  public var description: String {
    return String(format: "DefaultGroup(id=%@,privateState=%@,creatorID=%@,name=%@,desc=%@,avatarURL=%@,lang=%@,createdAt=%d,metadata=%@,count=%d,updatedAt=%d)", id.uuidString, privateState.description, creatorID.uuidString, name, desc, avatarURL, lang, createdAt, metadata.base64EncodedString(), count, updatedAt)
  }
}

public protocol GroupUser : User {
  /**
   - The state of this relationship
   */
  var state : GroupState { get }
}

internal struct DefaultGroupUser : GroupUser {
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
  let state : GroupState
  
  internal init(from proto: Server_GroupUser) {
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
    
    state = GroupState.make(from: proto.state)
  }
  
  public var description: String {
    return String(format: "DefaultGroupUser(avatarURL=%@,createdAt=%d,fullname=%@,handle=%@,id=%@,lang=%@,lastOnlineAt=%d,location=%@,metadata=%@,timezone=%@,updatedAt=%d,state=%@)", avatarURL, createdAt, fullname, handle, id.uuidString, lang, lastOnlineAt, location, metadata.base64EncodedString(), timezone, updatedAt, state.rawValue)
  }
}

public protocol GroupSelf : Group {
  /**
   - The state of this relationship
   */
  var state : GroupState { get }
}

internal struct DefaultGroupSelf : GroupSelf {
  let id : UUID
  let privateState : Bool
  let creatorID : UUID
  let name : String
  let desc : String
  let avatarURL : String
  let lang : String
  let metadata : Data
  let count : Int
  let createdAt : Int
  let updatedAt : Int
  let state : GroupState
  
  internal init(from proto: Server_TGroupsSelf.GroupSelf) {
    name = proto.group.name
    desc = proto.group.description_p
    avatarURL = proto.group.avatarURL
    lang = proto.group.lang
    metadata = proto.group.metadata
    count = Int(proto.group.count)
    createdAt = Int(proto.group.createdAt)
    updatedAt = Int(proto.group.updatedAt)
    privateState = proto.group.private
    
    id = proto.group.id.withUnsafeBytes { bytes in
      return NSUUID.init(uuidBytes: bytes) as UUID
    }
    
    creatorID = proto.group.creatorID.withUnsafeBytes { bytes in
      return NSUUID.init(uuidBytes: bytes) as UUID
    }
    
    state = GroupState.make(from: proto.state)
  }
  
  public var description: String {
    return String(format: "DefaultGroupSelf(id=%@,privateState=%@,creatorID=%@,name=%@,desc=%@,avatarURL=%@,lang=%@,createdAt=%d,metadata=%@,count=%d,updatedAt=%d,state=%@)", id.uuidString, privateState.description, creatorID.uuidString, name, desc, avatarURL, lang, createdAt, metadata.base64EncodedString(), count, updatedAt, state.rawValue)
  }
}

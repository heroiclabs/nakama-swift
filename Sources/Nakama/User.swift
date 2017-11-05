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

public protocol User : CustomStringConvertible {
  /**
   - Returns: A URL string which points at an avatar image or similar.
   */
  var avatarURL : String { get }
  
  /**
   - Returns: UTC timestamp when the user was created.
   */
  var createdAt : Int { get }
  
  /**
   - Returns: The full name for a user.
   */
  var fullname : String { get }
  
  /**
   - Returns: The handle (nickname) of the user.
   */
  var handle : String { get }
  
  /**
   - Returns: The ID of the user.
   */
  var id : String { get }
  
  /**
   - Returns: The (BCP-47) lang tag set by the user.
   */
  var lang : String { get }
  
  /**
   - Returns: UTC timestamp when the user was last online.
   */
  var lastOnlineAt : Int { get }
  
  /**
   - Returns: The location set by the user.
   */
  var location : String { get }
  
  /**
   - Returns: The metadata stored for the user.
   */
  var metadata : String { get }
  
  /**
   - Returns: The timezone set by the user.
   */
  var timezone : String { get }
  
  /**
   - Returns: UTC timestamp when the user was updated.
   */
  var updatedAt : Int { get }
}

internal struct DefaultUser : User {
  let avatarURL : String
  let createdAt : Int
  let fullname : String
  let handle : String
  let id : String
  let lang : String
  let lastOnlineAt : Int
  let location : String
  let metadata : String
  let timezone : String
  let updatedAt : Int
  
  internal init(from proto: Server_User) {
    id = proto.id
    avatarURL = proto.avatarURL
    createdAt = Int(proto.createdAt)
    fullname = proto.fullname
    handle = proto.handle
    lang = proto.lang
    lastOnlineAt = Int(proto.lastOnlineAt)
    location = proto.location
    metadata = proto.metadata
    timezone = proto.timezone
    updatedAt = Int(proto.updatedAt)
  }
  
  public var description: String {
    return String(format: "DefaultUser(avatarURL=%@,createdAt=%d,fullname=%@,handle=%@,id=%@,lang=%@,lastOnlineAt=%d,location=%@,metadata=%@,timezone=%@,updatedAt=%d)", avatarURL, createdAt, fullname, handle, id, lang, lastOnlineAt, location, metadata, timezone, updatedAt)
  }
}

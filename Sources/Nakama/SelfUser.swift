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

public protocol SelfUser : User {
  /**
   - Returns: The custom ID linked with the user.
   */
  var customID : String { get }
  
  /**
   - Returns: A list of device IDs linked with the user.
   */
  var deviceIDs : [String] { get }
  
  /**
   - Returns: The email address linked with the user.
   */
  var email : String { get }
  
  /**
   - Returns: The Facebook ID linked with the user.
   */
  var facebookID : String { get }
  
  /**
   - Returns: The Game Center ID linked with the user.
   */
  var gameCenterID : String { get }
  
  /**
   - Returns: The Google ID linked with the user.
   */
  var googleID : String { get }
  
  /**
   - Returns: The Steam ID linked with the user.
   */
  var steamID : String { get }
  
  /**
   - Returns: True if the email address for the user is verified.
   */
  var verified : Bool { get }
}

internal struct DefaultSelf : SelfUser {
  let avatarURL: String
  let createdAt : Int
  let fullname : String
  let handle : String
  let id : UUID
  let lang : String
  let lastOnlineAt : Int
  let location : String
  let metadata : String
  let timezone : String
  let updatedAt : Int
  
  let customID : String
  let deviceIDs : [String]
  let email : String
  let facebookID : String
  let gameCenterID : String
  let googleID : String
  let steamID : String
  let verified : Bool
  
  internal init(from proto: Server_TSelf) {
    let nkself = proto.self_p
    customID = nkself.customID
    deviceIDs = nkself.deviceIds
    email = nkself.email
    facebookID = nkself.facebookID
    gameCenterID = nkself.gamecenterID
    googleID = nkself.googleID
    steamID = nkself.steamID
    verified = nkself.verified
    
    avatarURL = nkself.user.avatarURL
    createdAt = Int(nkself.user.createdAt)
    fullname = nkself.user.fullname
    handle = nkself.user.handle
    lang = nkself.user.lang
    lastOnlineAt = Int(nkself.user.lastOnlineAt)
    location = nkself.user.location
    metadata = nkself.user.metadata
    timezone = nkself.user.timezone
    updatedAt = Int(nkself.user.updatedAt)
    
    
    id = NakamaId.convert(uuidBase64: nkself.user.id)
  }
  
  public var description: String {
    return String(format: "DefaultSelf(customID=%@,deviceIDs=%@,email=%@,facebookID=%@,gameCenterID=%@,googleID=%@,steamID=%@,verified=%@,avatarURL=%@,createdAt=%d,fullname=%@,handle=%@,id=%@,lang=%@,lastOnlineAt=%d,location=%@,metadata=%@,timezone=%@,updatedAt=%d)", customID, deviceIDs, email, facebookID, gameCenterID, googleID, steamID, verified.description, avatarURL, createdAt, fullname, handle, id.uuidString, lang, lastOnlineAt, location, metadata, timezone, updatedAt)
  }
}

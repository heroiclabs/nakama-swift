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

public struct SelfUpdateMessage : CollatedMessage {
  public var handle : String?
  public var fullname: String?
  public var timezone: String?
  public var location: String?
  public var lang: String?
  public var metadata: Data?
  public var avatarURL: String?
  
  public init(){}
  
  public func serialize(collationID: String) -> Data? {
    var update = Server_TSelfUpdate()
    
    if let _handle = handle {
      update.handle = _handle
    }
    
    if let _avatarURL = avatarURL{
      update.avatarURL = _avatarURL
    }
    
    if let _fullname = fullname {
      update.fullname = _fullname
    }
    
    if let _timezone = timezone{
      update.timezone = _timezone
    }
    
    if let _location = location {
      update.location = _location
    }
    
    if let _lang = lang {
      update.lang = _lang
    }
    
    if let _metadata = metadata {
      update.metadata = String(data: _metadata, encoding: .utf8)!
    }
    
    var envelope = Server_Envelope()
    envelope.selfUpdate = update
    envelope.collationID = collationID

    return try! envelope.serializedData()
  }
  
  public var description: String {
    var _metadata = ""
    if let m = metadata {
      _metadata = String(data: m, encoding: .utf8)!
    }
    
    return String(format: "SelfUpdateMessage(handle=%@,avatarURL=%@,fullname=%@,timezone=%@,location=%@,lang=%@,metadata=%@)", handle ?? "", avatarURL ?? "", fullname ?? "", timezone ?? "", location ?? "", lang ?? "", _metadata)
  }
  
}

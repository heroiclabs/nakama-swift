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
  public private(set) var handle : String?
  public private(set) var fullname: String?
  public private(set) var timezone: String?
  public private(set) var location: String?
  public private(set) var lang: String?
  public private(set) var metadata: Data?
  public private(set) var avatarURL: String?
  
  public init(){}
  
  public mutating func setHandle(handle: String) -> SelfUpdateMessage {
    self.handle = handle
    return self;
  }
  
  public mutating func setFullname(fullname: String) -> SelfUpdateMessage {
    self.fullname = fullname
    return self;
  }
  
  public mutating func setTimezone(timezone: String) -> SelfUpdateMessage {
    self.timezone = timezone
    return self;
  }
  
  public mutating func setLocation(location: String) -> SelfUpdateMessage {
    self.location = location
    return self;
  }
  
  public mutating func setLang(lang: String) -> SelfUpdateMessage {
    self.lang = lang
    return self;
  }
  
  public mutating func setMetadata(metadata: Data) -> SelfUpdateMessage {
    self.metadata = metadata
    return self;
  }
  
  public mutating func setAvatarUrl(avatarUrl: String) -> SelfUpdateMessage {
    self.avatarURL = avatarUrl
    return self;
  }
  
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
      update.metadata = _metadata
    }
    
    var envelope = Server_Envelope()
    envelope.selfUpdate = update
    envelope.collationID = collationID

    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "SelfUpdateMessage(handle=%@,avatarURL=%@,fullname=%@,timezone=%@,location=%@,lang=%@,metadata=%@)", handle ?? "", avatarURL ?? "", fullname ?? "", timezone ?? "", location ?? "", lang ?? "", metadata?.base64EncodedString() ?? "nil")
  }
  
}

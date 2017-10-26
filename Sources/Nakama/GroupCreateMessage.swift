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

public struct GroupCreateMessage : CollatedMessage {
  /**
   NOTE: The server only processes the first item of the list, and will ignore and logs a warning message for other items.
   */
  public var groupsCreate: [GroupCreate] = []
  
  public init(){}
  
  public func serialize(collationID: String) -> Data? {
    var proto = Server_TGroupsCreate()
    
    for groupCreate in groupsCreate {
      var gc = Server_TGroupsCreate.GroupCreate()
      gc.name = groupCreate.name
      
      if let desc = groupCreate.desc {
        gc.description_p = desc
      }
      if let avatarURL = groupCreate.avatarURL {
        gc.avatarURL = avatarURL
      }
      if let lang = groupCreate.lang {
        gc.lang = lang
      }
      if let metadata = groupCreate.metadata {
        gc.metadata = metadata
      }
      if let privateGroup = groupCreate.privateGroup {
        gc.private = privateGroup
      }
      
      proto.groups.append(gc)
    }
    
    var envelope = Server_Envelope()
    envelope.groupsCreate = proto
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "GroupCreateMessage(groupsCreate=%@)", groupsCreate)
  }
}

public struct GroupCreate : CustomStringConvertible {
  public var name: String
  public var desc: String?
  public var avatarURL: String?
  public var lang: String?
  public var metadata: Data?
  public var privateGroup: Bool?
  
  public init(name: String){
      self.name = name
  }
  
  public var description: String {
    return String(format: "GroupCreate(name=%@, description=%@, avatarURL=%@, lang=%@, metadata=%@, private=%@)", name, desc ?? "", avatarURL ?? "", lang ?? "", metadata?.base64EncodedString() ?? "", privateGroup?.description ?? "false")
  }
}


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

public struct GroupUpdateMessage : CollatedMessage {
  /**
   NOTE: The server only processes the first item of the list, and will ignore and logs a warning message for other items.
   */
  public var groupsUpdate: [GroupUpdate] = []
  
  public init(){}
  
  public func serialize(collationID: String) -> Data? {
    var proto = Server_TGroupsUpdate()
    
    for groupUpdate in groupsUpdate {
      var gu = Server_TGroupsUpdate.GroupUpdate()
      gu.groupID = NakamaId.convert(uuid: groupUpdate.groupID)
      
      if let name = groupUpdate.name {
        gu.name = name
      }
      if let desc = groupUpdate.desc {
        gu.description_p = desc
      }
      if let avatarURL = groupUpdate.avatarURL {
        gu.avatarURL = avatarURL
      }
      if let lang = groupUpdate.lang {
        gu.lang = lang
      }
      if let metadata = groupUpdate.metadata {
        gu.metadata = String.init(data: metadata, encoding: .utf8)!
      }
      if let privateGroup = groupUpdate.privateGroup {
        gu.private = privateGroup
      }
      
      proto.groups.append(gu)
    }
    
    var envelope = Server_Envelope()
    envelope.groupsUpdate = proto
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "GroupUpdateMessage(groupsUpdate=%@)", groupsUpdate)
  }
}

public struct GroupUpdate : CustomStringConvertible {
  public var groupID: UUID
  public var name: String?
  public var desc: String?
  public var avatarURL: String?
  public var lang: String?
  public var metadata: Data?
  public var privateGroup: Bool?
  
  public init(groupID: UUID){
    self.groupID = groupID
  }
  
  public var description: String {
    var _metadata = ""
    if let m = metadata {
      _metadata = String(data: m, encoding: .utf8)!
    }
    
    return String(format: "GroupUpdate(groupID=%@,name=%@, description=%@, avatarURL=%@, lang=%@, metadata=%@, private=%@)", groupID.uuidString, name ?? "", desc ?? "", avatarURL ?? "", lang ?? "", _metadata, privateGroup?.description ?? "false")
  }
}

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

public struct GroupPromoteUserMessage : CollatedMessage {
  
  /**
   List of a map of Group ID to User ID
   NOTE: The server only processes the first item of the list, and will ignore and logs a warning message for other items.
   */
  public var groupUsers : [(groupID: UUID, userID: UUID)] = []
  
  public init(){}
  
  public func serialize(collationID: String) -> Data? {
    var proto = Server_TGroupUsersPromote()
    
    for gu in groupUsers {
      var userPromote = Server_TGroupUsersPromote.GroupUserPromote()
      userPromote.groupID = NakamaId.convert(uuid: gu.groupID)
      userPromote.userID = NakamaId.convert(uuid: gu.userID)
      proto.groupUsers.append(userPromote)
    }
    
    var envelope = Server_Envelope()
    envelope.groupUsersPromote = proto
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "GroupPromoteUserMessage(groupUsers=%@)", groupUsers)
  }
}




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

public struct NotificationRemoveMessage : CollatedMessage {
  public var notificationIds: [String] = []
  
  public init(){}
  
  public func serialize(collationID: String) -> Data? {
    var proto = Server_TNotificationsRemove()
    
    for id in notificationIds {
      proto.notificationIds.append(id)
    }
    
    var envelope = Server_Envelope()
    envelope.notificationsRemove = proto
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "NotificationRemoveMessage(ids=%@)", notificationIds)
  }
  
}





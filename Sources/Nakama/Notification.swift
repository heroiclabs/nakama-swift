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

public protocol Notification : CustomStringConvertible {
  /**
   Unique ID of this notification
   */
  var id : UUID { get }
  
  /**
   Notification subject
   */
  var subject : String { get }
  
  /**
   Notification content
   */
  var content : String { get }
  
  /**
   Code associated with this notification. Code <= 100 indicate system notifications. For more info, please check the following link:
   https://heroiclabs.com/docs/social-in-app-notifications/#notification-codes
   */
  var code : Int { get }
  
  /**
   Sender ID of this notifications. If this notification is a system generated notification, a sender ID would not be set.
   */
  var senderID : UUID? { get }
  
  /**
   When this notification was created
   */
  var createdAt : Int { get }
  
  /**
   When this notification will expire
   */
  var expiresAt : Int { get }
  
  /**
   If this notification is persisted to the database for later retrieval.
   */
  var persistent : Bool { get }
}

internal struct DefaultNotification : Notification {
  let id : UUID
  let subject : String
  let content : String
  let code : Int
  let senderID : UUID?
  let createdAt : Int
  let expiresAt : Int
  let persistent : Bool
  
  internal init(from proto: Server_Notification) {
    subject = proto.subject
    content = proto.content
    code = Int(proto.code)
    createdAt = Int(proto.createdAt)
    expiresAt = Int(proto.expiresAt)
    persistent = proto.persistent
    
    id = NakamaId.convert(uuidBase64: proto.id)
    
    if !proto.senderID.isEmpty {
      senderID = NakamaId.convert(uuidBase64: proto.senderID)
    } else {
      senderID = nil
    }
  }
  
  public var description: String {
    return String(format: "DefaultNotification(id=%@,subject=%@,content=%@,code=%d,senderID=%@,createdAt=%d,expiresAt=%d,persistent=%@)", id.uuidString, subject, content, code, senderID?.uuidString ?? "", createdAt, expiresAt, persistent.description)
  }
}

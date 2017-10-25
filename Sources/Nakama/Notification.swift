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
  var id : UUID { get }
  var subject : String { get }
  var content : Data { get }
  var code : Int { get }
  var senderID : UUID? { get }
  var createdAt : Int { get }
  var expiresAt : Int { get }
  var persistent : Bool { get }
}

internal struct DefaultNotification : Notification {
  let id : UUID
  let subject : String
  let content : Data
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
    
    id = proto.id.withUnsafeBytes { bytes in
      return NSUUID.init(uuidBytes: bytes) as UUID
    }
    
    if !proto.senderID.isEmpty {
      senderID = proto.senderID.withUnsafeBytes { bytes in
        return NSUUID.init(uuidBytes: bytes) as UUID
      }
    } else {
      senderID = nil
    }
  }
  
  public var description: String {
    return String(format: "DefaultNotification(id=%@,subject=%@,content=%@,code=%d,senderID=%@,createdAt=%d,expiresAt=%d,persistent=%@)", id.uuidString, subject, content.base64EncodedString(), code, senderID?.uuidString ?? "", createdAt, expiresAt, persistent.description)
  }
}

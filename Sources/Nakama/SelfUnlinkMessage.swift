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

public struct SelfUnlinkMessage : CollatedMessage {
  private let payload: Server_TUnlink
  
  public init(device id: String){
    var proto = Server_TUnlink()
    proto.device = id
    
    payload = proto
  }
  
  public init(custom id: String){
    var proto = Server_TUnlink()
    proto.custom = id
    
    payload = proto
  }
  
  public init(facebook id: String){
    var proto = Server_TUnlink()
    proto.facebook = id
    
    payload = proto
  }
  
  public init(google id: String){
    var proto = Server_TUnlink()
    proto.google = id
    
    payload = proto
  }
  
  public init(email address: String){
    var proto = Server_TUnlink()
    proto.email = address
    
    payload = proto
  }
  
  public init(gamecenter id: String) {
    var proto = Server_TUnlink()
    proto.gameCenter = id
    
    payload = proto
  }
  
  public init(steam id: String) {
    var proto = Server_TUnlink()
    proto.steam = id
    
    payload = proto
  }
  
  
  public func serialize(collationID: String) -> Data? {
    var envelope = Server_Envelope()
    envelope.unlink = payload
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    switch payload.id! {
    case .device(let device):
      return String(format: "SelfUnlinkMessage(device=%@)", device)
    case .custom(let custom):
      return String(format: "SelfUnlinkMessage(custom=%@)", custom)
    case .facebook(let id):
      return String(format: "SelfUnlinkMessage(facebook=%@)", id)
    case .google(let id):
      return String(format: "SelfUnlinkMessage(google=%@)", id)
    case .steam(let id):
      return String(format: "SelfUnlinkMessage(steam=%@)", id)
    case .email(let email):
      return String(format: "SelfUnlinkMessage(email=%@)", email)
    case .gameCenter(let id):
      return String(format: "SelfUnlinkMessage(gamecenter=%@)", id)
    }
  }
  
}

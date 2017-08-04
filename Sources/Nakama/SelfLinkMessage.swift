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

public struct SelfLinkMessage : CollatedMessage {
  private let payload: Server_TLink
  
  public init(device id: String){
    var proto = Server_TLink()
    proto.device = id
    
    payload = proto
  }
  
  public init(custom id: String){
    var proto = Server_TLink()
    proto.custom = id
    
    payload = proto
  }
  
  public init(facebook token: String){
    var proto = Server_TLink()
    proto.facebook = token
    
    payload = proto
  }
  
  public init(google token: String){
    var proto = Server_TLink()
    proto.google = token
    
    payload = proto
  }
  
  public init(steam token:String) {
    var proto = Server_TLink()
    proto.steam = token
    
    payload = proto
  }
  
  public init(email address: String, password: String){
    var proto = Server_TLink()
    proto.email = Server_AuthenticateRequest.Email()
    proto.email.email = address
    proto.email.password = password
    
    payload = proto
  }
  
  public init(gamecenter bundleID:String, playerID:String, publicKeyURL:String, salt:String, timestamp:Int, signature:String) {
    var proto = Server_TLink()
    proto.gameCenter = Server_AuthenticateRequest.GameCenter()
    proto.gameCenter.bundleID = bundleID
    proto.gameCenter.playerID = playerID
    proto.gameCenter.publicKeyURL = publicKeyURL
    proto.gameCenter.salt = salt
    proto.gameCenter.timestamp = Int64(timestamp)
    proto.gameCenter.signature = signature
    
    payload = proto
  }
  
  public func serialize(collationID: String) -> Data? {
    var envelope = Server_Envelope()
    envelope.link = payload
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    switch payload.id! {
    case .device(let device):
      return String(format: "SelfLinkMessage(device=%@)", device)
    case .custom(let custom):
      return String(format: "SelfLinkMessage(custom=%@)", custom)
    case .facebook(let token):
      return String(format: "SelfLinkMessage(facebook=%@)", token)
    case .google(let token):
      return String(format: "SelfLinkMessage(google=%@)", token)
    case .steam(let token):
      return String(format: "SelfLinkMessage(steam=%@)", token)
    case .email(let email):
      return String(format: "SelfLinkMessage(email=%@,password=%@)", email.email, email.password)
    case .gameCenter(let gc):
      return String(format: "SelfLinkMessage(game_center=(bundle_id=%@,player_id=%@,public_key_url=%@,salt=%@,timestamp=%@,signature=%@))", gc.bundleID, gc.playerID, gc.publicKeyURL, gc.salt, gc.timestamp, gc.signature)
    }
  }
  
}

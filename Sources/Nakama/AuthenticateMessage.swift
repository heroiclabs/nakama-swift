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

public struct AuthenticateMessage : Message {
  private let payload : Server_AuthenticateRequest
  
  public init(device id:String) {
    var s = Server_AuthenticateRequest()
    s.device = id
    payload = s
  }
  
  public init(custom id:String) {
    var s = Server_AuthenticateRequest()
    s.custom = id
    payload = s
  }
  
  public init(facebook token:String) {
    var s = Server_AuthenticateRequest()
    s.facebook = token
    payload = s
  }
  
  public init(google token:String) {
    var s = Server_AuthenticateRequest()
    s.google = token
    payload = s
  }
  
  public init(steam token:String) {
    var proto = Server_AuthenticateRequest()
    proto.steam = token
    payload = proto
  }
  
  public init(email address:String, password:String) {
    var s = Server_AuthenticateRequest()
    s.email = Server_AuthenticateRequest.Email()
    s.email.email = address
    s.email.password = password
    payload = s
  }
  
  public init(gamecenter bundleID:String, playerID:String, publicKeyURL:String, salt:String, timestamp:Int, signature:String) {
    var s = Server_AuthenticateRequest()
    s.gameCenter = Server_AuthenticateRequest.GameCenter()
    s.gameCenter.bundleID = bundleID
    s.gameCenter.playerID = playerID
    s.gameCenter.publicKeyURL = publicKeyURL
    s.gameCenter.salt = salt
    s.gameCenter.timestamp = Int64(timestamp)
    s.gameCenter.signature = signature
    payload = s
  }
  
  public func serialize() -> Data? {
    return try! payload.serializedData()
  }
  
  public var description: String {
    switch payload.id! {
    case .device(let device):
      return String(format: "AuthenticateMessage(device=%@)", device)
    case .custom(let custom):
      return String(format: "AuthenticateMessage(custom=%@)", custom)
    case .facebook(let token):
      return String(format: "AuthenticateMessage(facebook=%@)", token)
    case .google(let token):
      return String(format: "AuthenticateMessage(google=%@)", token)
    case .steam(let token):
      return String(format: "AuthenticateMessage(steam=%@)", token)
    case .email(let email):
      return String(format: "AuthenticateMessage(email=%@,password=%@)", email.email, email.password)
    case .gameCenter(let gc):
      return String(format: "AuthenticateMessage(gamecenter=(bundle_id=%@,player_id=%@,public_key_url=%@,salt=%@,timestamp=%@,signature=%@))", gc.bundleID, gc.playerID, gc.publicKeyURL, gc.salt, gc.timestamp, gc.signature)
    }
  }
  
}

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
  
  internal init(msg: Server_AuthenticateRequest) {
    self.payload = msg
  }
  
  public func serialize() -> Data? {
    return try! payload.serializedData()
  }
  
  public var description: String {
    switch payload.id! {
    case .device(let device):
      return String(format: "DefaultAuthenticateMessage(device=%@)", device)
    case .custom(let custom):
      return String(format: "DefaultAuthenticateMessage(custom=%@)", custom)
    case .facebook(let token):
      return String(format: "DefaultAuthenticateMessage(facebook=%@)", token)
    case .google(let token):
      return String(format: "Default AuthenticateMessage(google=%@)", token)
    case .steam(let token):
      return String(format: "DefaultAuthenticateMessage(steam=%@)", token)
    case .email(let email):
      return String(format: "DefaultAuthenticateMessage(email=%@,password=%@)", email.email, email.password)
    case .gameCenter(let gc):
      return String(format: "DefaultAuthenticateMessage(game_center=(bundle_id=%@,player_id=%@,public_key_url=%@,salt=%@,timestamp=%@,signature=%@))", gc.bundleID, gc.playerID, gc.publicKeyURL, gc.salt, gc.timestamp, gc.signature)
    }
  }
  
  public static func device(id:String) -> AuthenticateMessage {
    var s = Server_AuthenticateRequest()
    s.device = id
    return AuthenticateMessage(msg: s)
  }
  
  public static func custom(id:String) -> AuthenticateMessage {
    var s = Server_AuthenticateRequest()
    s.custom = id
    return AuthenticateMessage(msg: s)
  }
  
  public static func facebook(token:String) -> AuthenticateMessage {
    var s = Server_AuthenticateRequest()
    s.facebook = token
    return AuthenticateMessage(msg: s)
  }
  
  public static func google(token:String) -> AuthenticateMessage {
    var s = Server_AuthenticateRequest()
    s.google = token
    return AuthenticateMessage(msg: s)
  }
  
  public static func email(address:String, password:String) -> AuthenticateMessage {
    var s = Server_AuthenticateRequest()
    s.email = Server_AuthenticateRequest.Email()
    s.email.email = address
    s.email.password = password
    return AuthenticateMessage(msg: s)
  }
  
  public static func gameCenter(bundleID:String, playerID:String, publicKeyURL:String, salt:String, timestamp:Int, signature:String) -> AuthenticateMessage {
    var s = Server_AuthenticateRequest()
    s.gameCenter = Server_AuthenticateRequest.GameCenter()
    s.gameCenter.bundleID = bundleID
    s.gameCenter.playerID = playerID
    s.gameCenter.publicKeyURL = publicKeyURL
    s.gameCenter.salt = salt
    s.gameCenter.timestamp = Int64(timestamp)
    s.gameCenter.signature = signature
    return AuthenticateMessage(msg: s)
  }

}

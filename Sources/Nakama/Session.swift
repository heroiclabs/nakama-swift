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

/**
 A session connects a user to the server.
 */
public protocol Session : CustomStringConvertible {
  /**
   UTC timestamp when the session was restored.
   */
  var createdAt: Int { get }

  /**
   UTC timestamp when the session expires.
   */
  var expiresAt: Int { get }

  /**
   The handle (nickname) of the user.
   */
  var handle: String { get }

  /**
   The ID of the user.
   */
  var userID: UUID { get }

  /**
   The session token returned by the server after register or login.
   */
  var token: String { get }

  /**
   - Parameter currentTimeSince1970: The current time in milliseconds to compare with token.
   - Returns: True if the session has expired.
   */
  func isExpired(currentTimeSince1970 : TimeInterval) -> Bool
}

public struct DefaultSession : Session {
  public let token: String
  public let userID: UUID
  public let handle: String
  public let expiresAt: Int
  public let createdAt: Int

  internal init(token: String) {
    let encoded: [String] = token.components(separatedBy: ".");
    precondition(encoded.count == 3, "Invalid token provided")
    
    var encodedToken = encoded[1]
    encodedToken = encodedToken.padding(toLength: ((encodedToken.count+3)/4)*4, withPad: "=", startingAt: 0)
    
    let decodedData = Data(base64Encoded: encodedToken)
    let jsonMap = try? JSONSerialization.jsonObject(with: decodedData!, options: []) as! [String: Any]
    
    createdAt = Int(Date().timeIntervalSince1970 * 1000.0)
    expiresAt = Int(round(jsonMap?["exp"] as! Double * 1000.0))
    handle = jsonMap?["han"] as! String
    
    let uid = jsonMap?["uid"] as! String
    userID = NakamaId.convert(uuidBase64: uid)
    
    self.token = token;
  }
  
  public func isExpired(currentTimeSince1970: TimeInterval) -> Bool {
    return !currentTimeSince1970.isLess(than: Double(expiresAt))
  }
  
  public var description: String {
    return String(format: "userID=%@,handle=%@,expiresAt=%d,createdAt=%d,token=%@", userID.uuidString, handle, expiresAt, createdAt, token)
  }
  
  /**
   - Parameter token: The token to restore session from.
   - Returns: A new Session object that is restored.
   */
  public static func restore(token: String) -> Session {
    return DefaultSession.init(token: token)
  }
}

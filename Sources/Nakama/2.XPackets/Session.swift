/*
 * Copyright 2018 Heroic Labs
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
     The session token returned by the server after register or login.
     */
var authToken: String { get }
  /**
   UTC timestamp when the session was restored.
   */
  var createTime: Int { get }

  /**
   UTC timestamp when the session expires.
   */
  var expireTime: Int { get }

    
    /**
     The username of the user.
     */
    var userName: String? { get }

  /**
   The ID of the user.
   */
  var userID: String { get }

    /**
     True if the user of the session was just created
    */
    var created: Bool { get}
    
  /**
   - Parameter currentTimeSince1970: The current time in milliseconds to compare with token.
   - Returns: True if the session has expired.
   */
  func isExpired(currentTimeSince1970 : TimeInterval) -> Bool
}

public struct DefaultSession : Session {
    public var created: Bool
    
    public var userID: String
    
    public var authToken: String
    
    public var createTime: Int
    
    public var expireTime: Int

    public var userName: String?
    


    internal init(token: String, created: Bool) {
    let encoded: [String] = token.components(separatedBy: ".");
    precondition(encoded.count == 3, "Invalid token provided")
    
    var encodedToken = encoded[1]
    encodedToken = encodedToken.padding(toLength: ((encodedToken.count+3)/4)*4, withPad: "=", startingAt: 0)
    
    let decodedData = Data(base64Encoded: encodedToken)
    let jsonMap = try? JSONSerialization.jsonObject(with: decodedData!, options: []) as! [String: Any]
    
    createTime = Int(Date().timeIntervalSince1970 * 1000.0)
    expireTime = Int(round(jsonMap?["exp"] as! Double * 1000.0))
        if let n = jsonMap?["usn"]{
            userName = n as! String
        }
    
    userID = jsonMap?["uid"] as! String
    self.created = created
    self.authToken = token;
  }
  
  public func isExpired(currentTimeSince1970: TimeInterval) -> Bool {
    return !currentTimeSince1970.isLess(than: Double(expireTime))
  }
  
  public var description: String {
    return String(format: "userID=%@,userName=%@,expiresAt=%d,createdAt=%d,token=%@", userID, userName ?? "", expireTime, createTime, authToken)
  }
  
  /**
   - Parameter token: The token to restore session from.
   - Returns: A new Session object that is restored.
   */
  public static func restore(token: String) -> Session {
    return DefaultSession.init(token: token, created: false)
  }
}

/*
 * Copyright 2021 The Nakama Authors
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

public protocol Session {
    /*
     * The authentication token used to construct this session.
     */
    var token: String { get }
    
    /*
     * True if the user account for this session was just created.
     */
    var created: Bool { get }
    
    /*
     * The timestamp in seconds when this session object was created.
     */
    var createTime: Date { get }
    
    /*
     * True if the session has expired against the current time.
     */
    var expired: Bool { get }
    
    /*
     * True if the session has expired against the current time.
     */
    func expired(date: Date) -> Bool
    
    /*
     * The timestamp in seconds when this session will expire.
     */
    var expiryTime: Date { get }
    
    /*
     * The username of the user who owns this session.
     */
    var username: String { get }
    
    /*
     * The ID of the user who owns this session.
     */
    var userId: String { get }
    
    /*
     * Get session vars.
     */
    var sessionVars: [String:String] { get }
}

class DefaultSession: Session {
    var token: String
    var created: Bool
    var createTime: Date
    var expiryTime: Date
    var username: String
    var userId: String
    var sessionVars: [String : String]
    
    init(token: String, created: Bool) {
        self.token = token
        self.created = created
        self.createTime = Date()
        
        let decoded = token.components(separatedBy: ".")
        var claims = decoded[1]
        claims = claims.padding(toLength: ((claims.count+3)/4)*4, withPad: "=", startingAt: 0)
        
        let jsonData = Data(base64Encoded: claims)!
        let jsonDict =  try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:AnyObject]
        self.expiryTime = Date(timeIntervalSince1970: (jsonDict["exp"] as! Double))
        self.userId = jsonDict["uid"] as! String
        self.username = jsonDict["usn"] as! String
        self.sessionVars = jsonDict["vrs"] as! [String:String]
    }
    
    var expired: Bool {
        get {
            let now = Date()
            return now > self.expiryTime
        }
    }
    
    func expired(date: Date) -> Bool {
        return date > self.expiryTime
    }
    
    public static func restore(token: String) -> Session {
        return DefaultSession(token: token, created: false)
    }
}

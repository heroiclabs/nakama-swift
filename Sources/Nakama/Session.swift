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
import GRPC

public protocol Session {
    /// The authentication token used to construct this session.
    var token: String { get }
    
    /// Refresh token that can be used for session token renewal.
    var refreshToken: String { get }
    
    /// If the user account for this session was just created.
    var created: Bool { get }
    
    /// The UNIX timestamp when this session was created.
    var createTime: Date { get }
    
    /// If the session has expired against the current time.
    var isExpired: Bool { get }
        
    /// The UNIX timestamp when this session will expire.
    var expiryTime: Date { get }
    
    /// If the refresh token has expired against current time.
    var isRefreshExpired: Bool { get }
    
    /// The UNIX timestamp when the refresh token will expire.
    var refreshExpiryTime: Date { get }
    
    /// The username of the user who owns this session.
    var username: String { get }
    
    /// The ID of the user who owns this session.
    var userId: String { get }
    
    /// Any custom properties associated with this session.
    var sessionVars: [String:String] { get }
    
    /// Check if the session has expired against the offset time.
    ///
    /// - Parameter offset: The time to compare against this session.
    func hasExpired(offset: Date) -> Bool
    
    /// Check if the refresh token has expired against the offset time.
    ///
    /// - Parameter offset: The time to compare against this refresh token.
    func hasRefreshExpired(offset: Date) -> Bool
}

public final class DefaultSession: Session {
    public var token: String
    public var refreshToken: String
    public var created: Bool
    public var createTime: Date
    public var expiryTime: Date
    public var refreshExpiryTime: Date
    public var username: String
    public var userId: String
    public var sessionVars: [String : String]
    
    init(token: String, refreshToken: String, created: Bool) {
        self.token = token
        self.refreshToken = refreshToken
        self.created = created
        self.createTime = Date()
        
        let decoded = token.components(separatedBy: ".")
        var claims = decoded[1]
        claims = claims.padding(toLength: ((claims.count+3)/4)*4, withPad: "=", startingAt: 0)
        
        let jsonData = Data(base64Encoded: claims)!
        let jsonDict =  try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:AnyObject]
        
        self.expiryTime = Date(timeIntervalSince1970: (jsonDict["exp"] as! Double))
        self.refreshExpiryTime = Date()
        self.userId = jsonDict["uid"] as! String
        self.username = jsonDict["usn"] as! String
        self.sessionVars = jsonDict.keys.contains("vrs") ? jsonDict["vrs"] as! [String : String] : [:]
        
        self.update(authToken: token, refreshToken: refreshToken)
    }
    
    public var isExpired: Bool {
        get {
            return hasExpired(offset: Date())
        }
    }
    
    public var isRefreshExpired: Bool {
        get {
            return hasRefreshExpired(offset: Date())
        }
    }
    
    public static func restore(token: String, refreshToken: String) -> Session {
        return DefaultSession(token: token, refreshToken: refreshToken, created: false)
    }
    
    public func hasExpired(offset: Date) -> Bool {
        let epoch = Date(timeIntervalSince1970: 0)
        return offset > epoch.addingTimeInterval(expiryTime.timeIntervalSince1970)
    }
    
    public func hasRefreshExpired(offset: Date) -> Bool {
        let epoch = Date(timeIntervalSince1970: 0)
        return offset > epoch.addingTimeInterval(refreshExpiryTime.timeIntervalSince1970)
    }
    
    /// Update the current session token with a new authorization token and refresh token.
    func update(authToken: String, refreshToken: String) {
        self.token = authToken
        self.refreshToken = refreshToken
        
        guard let decoded = authToken.decodedJWT() else { return }
        
        // Update
        if let uid = decoded["uid"] as? String { // User Id
            self.userId = uid
        }
        if let username = decoded["usn"] as? String { // Username
            self.username = username
        }
        if let expiry = decoded["exp"] as? Double {
            self.expiryTime = Date(timeIntervalSince1970: expiry)
        }
        if let vars = decoded["vrs"] as? [String:Any] { // Vars
            for (k, v) in vars {
                if let val = v as? String {
                    self.sessionVars[k] = val
                }
            }
        }
        if !refreshToken.isEmpty { // Update refresh expiry time
            if let decoded2 = refreshToken.decodedJWT(), let exp = decoded2["exp"] as? Double {
                self.refreshExpiryTime = Date(timeIntervalSince1970: exp)
            }
        }
    }
}

extension Session {
    var callOptions: CallOptions {
        var options = CallOptions()
        options.customMetadata.add(name: "authorization", value: "Bearer \(self.token)")
        return options
    }
}

extension String {
    func decodedJWT() -> [String:Any]? {
        let components = self.components(separatedBy: ".")
        guard components.count == 3 else { return nil }
        
        if let base64Encoded = Data(base64Encoded: components[1]), let jsonJWT = try? JSONSerialization.jsonObject(with: base64Encoded) as? [String:Any] {
            return jsonJWT
        }
        
        return nil
    }
}

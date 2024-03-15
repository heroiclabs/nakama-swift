/*
 * Copyright © 2024 The Satori Authors
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


/// A session authenticated for a user with Satori server.
public protocol Session {
    /// The authorization token used to construct this session.
    var authToken: String { get }
    
    /// The UNIX timestamp when this session will expire.
    var expireTime: Date { get }
    
    /// If the session has expired.
    var isExpired: Bool { get }
    
    /// If the refresh token has expired.
    var isRefreshExpired: Bool { get }
    
    /// The UNIX timestamp when the refresh token will expire.
    var refreshExpireTime: Date { get }
    
    /// Refresh token that can be used for session token renewal.
    var refreshToken: String { get }
    
    /// The ID of the user who owns this session.
    var identityId: String { get }
    
    /// Check the session has expired against the offset time.
    /// - Parameter offset: The datetime to compare against this session.
    /// - Returns: If the session has expired.
    func hasExpired(offset: Date) -> Bool
    
    /// Check if the refresh token has expired against the offset time.
    /// - Parameter offset: The datetime to compare against this refresh token.
    /// - Returns: If refresh token has expired.
    func hasRefreshExpired(offset: Date) -> Bool
}

public final class DefaultSession: Session {
    public var authToken: String
    public var refreshToken: String
    public var expireTime: Date
    public var refreshExpireTime: Date
    public var identityId: String
    public var sessionVars: [String:String]

    public var isExpired: Bool {
        return hasExpired(offset: Date())
    }

    public var isRefreshExpired: Bool {
        return hasRefreshExpired(offset: Date())
    }
    
    public func hasExpired(offset: Date) -> Bool {
        let epoch = Date(timeIntervalSince1970: 0)
        let expireDateTime = epoch.addingTimeInterval(expireTime.timeIntervalSince1970)
        return offset > expireDateTime
    }

    public func hasRefreshExpired(offset: Date) -> Bool {
        let epoch = Date(timeIntervalSince1970: 0)
        let expireDateTime = epoch.addingTimeInterval(refreshExpireTime.timeIntervalSince1970)
        return offset > expireDateTime
    }

    init(authToken: String, refreshToken: String) {
        self.authToken = authToken
        self.refreshToken = refreshToken

        let decoded = authToken.components(separatedBy: ".")
        var claims = decoded[1]
        claims = claims.padding(toLength: ((claims.count+3)/4)*4, withPad: "=", startingAt: 0)
        
        let jsonData = Data(base64Encoded: claims)!
        if let jsonDict =  try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:AnyObject] {
            self.expireTime = Date(timeIntervalSince1970: (jsonDict["exp"] as! Double))
            self.identityId = jsonDict["iid"] as! String
            self.sessionVars = jsonDict.keys.contains("vrs") ? jsonDict["vrs"] as! [String : String] : [:]
        } else {
            self.expireTime = Date()
            self.identityId = ""
            self.sessionVars = [:]
        }
        self.refreshExpireTime = Date()

        update(authToken: authToken, refreshToken: refreshToken)
    }

    public static func restore(authToken: String, refreshToken: String? = nil) -> Session? {
        guard !authToken.isEmpty else {
            return nil
        }
        return DefaultSession(authToken: authToken, refreshToken: refreshToken ?? "")
    }
    
    public func update(authToken: String, refreshToken: String) {
        self.authToken = authToken
        self.refreshToken = refreshToken
        
        guard let decoded = authToken.decodedJWT() else { return }
        
        if let iid = decoded["iid"] as? String {
            self.identityId = iid
        }
        if let expiry = decoded["exp"] as? Double {
            self.expireTime = Date(timeIntervalSince1970: expiry)
        }
        if let vars = decoded["vrs"] as? [String:Any] {
            for (k, v) in vars {
                if let val = v as? String {
                    self.sessionVars[k] = val
                }
            }
        }
        if !refreshToken.isEmpty {
            if let decoded2 = refreshToken.decodedJWT(), let exp = decoded2["exp"] as? Double {
                self.refreshExpireTime = Date(timeIntervalSince1970: exp)
            }
        }
    }
}

extension Session {
    var callOptions: CallOptions {
        var options = CallOptions()
        options.customMetadata.add(name: "authorization", value: "Bearer \(self.authToken)")
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

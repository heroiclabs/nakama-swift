/*
 * Copyright © 2023 Heroic Labs
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

/// A user in the server.
public struct ApiUser {
    /// The id of the user's account.
    public let id: String
    
    /// The Apple Sign In ID in the user's account.
    public let appleId: String
    
    /// A URL for an avatar image.
    public let avatarUrl: String
    
    /// The UNIX time when the user was created.
    public let createTime: Date
    
    /// The display name of the user.
    public let displayName: String
    
    /// Number of related edges to this user.
    public let edgeCount: Int
    
    /// The Facebook id in the user's account.
    public let facebookId: String
    
    /// The Facebook Instant Game ID in the user's account.
    public let facebookInstantGameId: String
    
    /// The Apple Game Center in of the user's account.
    public let gamecenterId: String
    
    /// The Google id in the user's account.
    public let googleId: String
    
    /// The language expected to be a tag which follows the BCP-47 spec.
    public let langTag: String
    
    /// The location set by the user.
    public let location: String
    
    /// Additional information stored as a JSON object.
    public let metadata: String
    
    /// Indicates whether the user is currently online.
    public let online: Bool
    
    /// The Steam id in the user's account.
    public let steamId: String
    
    /// The timezone set by the user.
    public let timezone: String
    
    /// The UNIX time when the user was last updated.
    public let updateTime: Date
    
    /// The username of the user's account.
    public let username: String
}

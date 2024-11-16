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
    public let id: String
    public let appleId: String
    public let avatarUrl: String
    public let createTime: Date
    public let displayName: String
    public let edgeCount: Int
    public let facebookId: String
    public let facebookInstantGameId: String
    public let gamecenterId: String
    public let googleId: String
    public let langTag: String
    public let location: String
    public let metadata: String
    public let online: Bool
    public let steamId: String
    public let timezone: String
    public let updateTime: Date
    public let username: String
}

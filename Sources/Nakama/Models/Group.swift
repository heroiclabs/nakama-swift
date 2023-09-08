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

/// A group in the server.
public struct Group {
    /// The id of a group.
    let id: String
    
    /// The id of the user who created the group.
    let creatorId: String
    
    /// The unique name of the group.
    let name: String
    
    /// A description for the group.
    let description: String
    
    /// The language expected to be a tag which follows the BCP-47 spec.
    let langTag: String
    
    /// Additional information stored as a JSON object.
    let metadata: String
    
    /// A URL for an avatar image.
    let avatarUrl: String
    
    /// Anyone can join open groups, otherwise only admins can accept members.
    let open: Bool
    
    /// The current count of all members in the group.
    let edgeCount: Int
    
    /// The maximum number of members allowed.
    let maxCount: Int
    
    /// The UNIX time when the group was created.
    let createTime: Date
    
    /// The UNIX time when the group was last updated.
    let updateTime: Date
}

/// One or more groups returned from a listing operation.
public struct GroupList {
    /// One or more groups.
    let groups: [Group]
    
    /// A cursor used to get the next page.
    let cursor: String
}

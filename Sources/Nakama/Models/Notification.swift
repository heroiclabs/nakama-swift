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

/// A notification in the server.
public struct ApiNotification {
    /// Category code for this notification.
    let code: Int
    
    /// Content of the notification in JSON.
    let content: String
    
    /// The UNIX time when the notification was created.
    let createTime: Date
    
    /// ID of the Notification.
    let id: String
    
    /// True if this notification was persisted to the database.
    let persistent: Bool
    
    /// ID of the sender, if a user. Otherwise 'null'.
    let senderId: String
    
    /// Subject of the notification.
    let subject: String
}

/// A collection of zero or more notifications.
public struct NotificationList {
    /// Use this cursor to paginate notifications. Cache this to catch up to new notifications.
    let cacheableCursor: String
    
    /// Collection of notifications.
    let notifications: [ApiNotification]
}

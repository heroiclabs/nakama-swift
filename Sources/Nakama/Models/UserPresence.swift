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

public final class UserPresence: Hashable {
    let userId: String
    let sessionId: String
    let username: String
    let persistence: Bool
    let status: String?
    
    init(userId: String, sessionId: String, username: String, persistence: Bool, status: String? = nil) {
        self.userId = userId
        self.sessionId = sessionId
        self.username = username
        self.persistence = persistence
        self.status = status
    }
    
    convenience init(from rtUserPresence: Nakama_Realtime_UserPresence) {
        self.init(
            userId: rtUserPresence.userID,
            sessionId: rtUserPresence.sessionID,
            username: rtUserPresence.username,
            persistence: rtUserPresence.persistence,
            status: rtUserPresence.status.value.isEmpty ? nil : rtUserPresence.status.value
        )
    }
    
    public static func == (lhs: UserPresence, rhs: UserPresence) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.userId)
    }
}

extension [UserPresence] {
    func copyJoinsAndLeaves(joins: [UserPresence], leaves: [UserPresence]) {
        var newPresences = Set(self)
        newPresences.formUnion(joins)
        newPresences.formUnion(leaves)
    }
}

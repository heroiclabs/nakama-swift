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

public class NakamaChannel {
    let id: String
    let presences: [UserPresence]
    let roomName: String
    let groupId: String
    let userIdOne: String
    let userIdTwo: String
    let selfPresence: UserPresence
    
    init(id: String, presences: [UserPresence], roomName: String, groupId: String, userIdOne: String, userIdTwo: String, selfPresence: UserPresence) {
        self.id = id
        self.presences = presences
        self.roomName = roomName
        self.groupId = groupId
        self.userIdOne = userIdOne
        self.userIdTwo = userIdTwo
        self.selfPresence = selfPresence
    }
    
    convenience init(from rtChannel: Nakama_Realtime_Channel) {
        self.init(
            id: rtChannel.id,
            presences: rtChannel.presences.map { UserPresence(from: $0) },
            roomName: rtChannel.roomName,
            groupId: rtChannel.groupID,
            userIdOne: rtChannel.userIDOne,
            userIdTwo: rtChannel.userIDTwo,
            selfPresence: rtChannel.self_p.toUserPresence()
        )
    }
}

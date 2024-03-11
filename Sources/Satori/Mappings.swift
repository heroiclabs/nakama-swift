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

extension Satori_Api_Session {
    func toSession() async -> SatoriSession {
        return SatoriSession(authToken: self.token, refreshToken: self.refreshToken)
    }
}

extension ApiSession {
    func toSession() async -> SatoriSession {
        return SatoriSession(authToken: self.token, refreshToken: self.refreshToken)
    }
}

extension Event {
    func toApiEvent() -> Satori_Api_Event {
        var event = Satori_Api_Event()
        event.name = self.name
        event.timestamp = self.timestamp.toProtobufTimestamp()
        if let id = self.id {
            event.id = id
        }
        if let metadata = self.metadata {
            event.metadata = metadata
        }
        if let value = self.value {
            event.value = value
        }
        return event
    }
}

extension Event {
    func toApiEvent() -> ApiEvent {
        let protobufTimestamp = self.timestamp.toProtobufTimestamp()
        let unixEpochString = protobufTimestamp.toDate().toRFC3339FormatString()
        return ApiEvent(
            id: self.id ?? "",
            metadata: self.metadata ?? [:],
            name: self.name, timestamp: unixEpochString,
            value: self.value ?? ""
        )
    }
}

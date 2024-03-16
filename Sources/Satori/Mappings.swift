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
    /// Map `Satori_Api_Session` object to `SatoriSession`.
    func toSession() -> DefaultSession {
        return DefaultSession(authToken: self.token, refreshToken: self.refreshToken)
    }
}

extension ApiSession {
    /// Map `ApiSession` object to `SatoriSession`.
    func toSession() -> DefaultSession {
        return DefaultSession(authToken: self.token, refreshToken: self.refreshToken)
    }
}

extension Session {
    /// Map `SatoriSession` object to `ApiSession`.
    func toApiSession() -> ApiSession {
        return ApiSession(properties: ApiProperties(), refreshToken: self.refreshToken, token: self.authToken)
    }
}

extension Event {
    /// Map Satori `Event` object to `Satori_Api_Event`.
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
    /// Map Satori `Event` object to `ApiEvent`.
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

extension ApiFlagList {
    /// Map `ApiFlagList` object to `FlagList`.
    func toFlagList() -> FlagList {
        return FlagList(flags: self.flags?.map { $0.toFlag() } ?? [])
    }
}

extension ApiFlag {
    /// Map `ApiFlag` object to `Flag`.
    func toFlag() -> Flag {
        return Flag(name: self.name, value: self.value, conditionChanged: self.conditionChanged ?? false)
    }
}

extension ApiExperimentList {
    /// Map `ApiExperimentList` object to `ExperimentList`.
    func toExperimentList() -> ExperimentList {
        return ExperimentList(experiments: self.experiments?.map { $0.toExperiment() } ?? [])
    }
}

extension ApiExperiment {
    /// Map `ApiExperiment` object to `Experiment`.
    func toExperiment() -> Experiment {
        return Experiment(name: self.name, value: self.value)
    }
}

extension ApiProperties {
    /// Map `ApiProperties` object to `Properties`.
    func toProperties() -> Properties {
        return Properties(
            computed: self.computed ?? [:],
            custom: self.custom ?? [:],
            default_: self.default_
        )
    }
}

extension ApiLiveEventList {
    /// Map `ApiLiveEventList` object to `LiveEventList`.
    func toLiveEventList() -> LiveEventList {
        return LiveEventList(liveEvents: self.liveEvents?.map { $0.toLiveEvent() } ?? [])
    }
}

extension ApiLiveEvent {
    /// Map `ApiLiveEvent` object to `LiveEvent`.
    func toLiveEvent() -> LiveEvent {
        return LiveEvent(
            activeEndTimeSec: self.activeEndTimeSec,
            activeStartTimeSec: activeStartTimeSec,
            description: description,
            id: id,
            name: name,
            value: value
        )
    }
}

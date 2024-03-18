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

/// An event to be published to the server.
public struct Event {
    /// The name of the event.
    let name: String
    
    /// The time when the event was triggered.
    let timestamp: Date
    
    /// Optional value.
    let value: String?
    
    /// Event metadata, if any.
    let metadata: [String: String]?
    
    /// Optional event ID assigned by the client, used to de-duplicate in retransmission scenarios.
    /// If not supplied the server will assign a randomly generated unique event identifier.
    let id: String?
    
    /// The event constructor.
    public init(name: String, timestamp: Date, value: String? = nil, metadata: [String: String]? = nil, id: String? = nil) {
        self.name = name
        self.timestamp = timestamp
        self.value = value
        self.metadata = metadata
        self.id = id
    }
}

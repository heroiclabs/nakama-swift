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

/// List of Live events.
public struct LiveEventList {
    /// Live events.
    let liveEvents: [LiveEvent]
}

/// A single live event.
public struct LiveEvent {
    /// End time of current event run.
    let activeEndTimeSec: String
    
    /// Start time of current event run.
    let activeStartTimeSec: String
    
    /// Description.
    let description: String
    
    /// The live event identifier.
    let id: String
    
    /// Name.
    let name: String
    
    /// Event value.
    let value: String
}

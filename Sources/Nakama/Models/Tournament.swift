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

public typealias TournamentOperator = LeaderboardOperator

/// A tournament on the server.
public struct Tournament {
    /// The ID of the tournament.
    let id: String
    
    /// The title for the tournament.
    let title: String
    
    /// The description of the tournament. May be blank.
    let description: String
    
    /// The category of the tournament. e.g. "vip" could be category 1.
    let category: Int
    
    /// ASC (0) or DESC (1) sort mode of scores in the tournament.
    let sortOrder: Int
    
    /// The current number of players in the tournament.
    let size: Int
    
    /// The maximum number of players for the tournament.
    let maxSize: Int
    
    /// The maximum score updates allowed per player for the current tournament.
    let maxNumScore: Int
    
    /// True if the tournament is active and can enter.
    let canEnter: Bool
    
    /// The UNIX time when the tournament stops being active until next reset.
    let endActive: Int
    
    /// The UNIX time when the tournament is next playable.
    let nextReset: Int
    
    /// Additional information stored as a JSON object.
    let metadata: String
}

public struct TournamentList {
    /// The list of tournaments returned.
    let tournaments: [Tournament]
    
    /// A pagination cursor
    let cursor: String
}

/// A set of tournament records which may be part of a tournament records page or a batch of individual records.
public struct TournamentRecordList {
    /// The cursor to send when retireving the next page.
    let nextCursor: String
    
    /// The cursor to send when retrieving the previous page.
    let prevCursor: String
    
    /// A batched set of tournament records belonging to specified owners.
    let ownerRecords: [LeaderboardRecord]
    
    /// A list of tournament records.
    let records: [LeaderboardRecord]
}

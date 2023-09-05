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

public enum LeaderboardOperator: Int {
    case noOverride = 0
    case best = 1
    case set = 2
    case increment = 3
    case decrement = 4
}

/// Leaderboard record with all scores and associated metadata.
public struct LeaderboardRecord {
    let createTime: Date
    let expiryTime: Date
    let updateTime: Date
    let leaderboardId: String
    let username: String
    let ownerId: String
    let score: Int
    let subScore: Int
    let metadata: String
    let numScore: Int
    let maxNumScore: Int
}

/// A set of leaderboard records, may be part of a leaderboard records page or a batch of individual records.
public struct LeaderboardRecordList {
    let nextCursor: String
    let prevCursor: String
    let ownerRecords: [LeaderboardRecord]
    let records: [LeaderboardRecord]
}

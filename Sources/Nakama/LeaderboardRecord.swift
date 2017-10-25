/*
 * Copyright 2017 Heroic Labs
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

public protocol LeaderboardRecord : CustomStringConvertible {
  /**
   - Returns: Leaderboard ID
   */
  var leaderboardID : UUID { get }
  
  /**
   - Returns: owner ID of the leaderboard record
   */
  var ownerID : UUID { get }
  
  /**
   - Returns: The handle of the owner, if owner is a user
   */
  var handle : String { get }
  
  /**
   - Returns: Lang tag associated with the record
   */
  var lang : String { get }
  
  /**
   - Returns: Location tag associated with the record
   */
  var location : String { get }
  
  /**
   - Returns: Timezone tag associated with the record
   */
  var timezone : String { get }
  
  /**
   - Returns: Record's rank
   */
  var rank : Int { get }
  
  /**
   - Returns: Records's score
   */
  var score : Int { get }
  
  var numScore : Int { get }
  
  /**
   - Returns: Metadata associated with the leaderboard record
   */
  var metadata : Data { get }
  
  /**
   - Returns: UTC timestamp when the rank was calculated.
   */
  var rankedAt : Int { get }
  
  /**
   - Returns: UTC timestamp when the record will be expired.
   */
  var expiresAt : Int { get }
  
  /**
   - Returns: UTC timestamp when the record was updated.
   */
  var updatedAt : Int { get }
}

internal struct DefaultLeaderboardRecord : LeaderboardRecord {
  let leaderboardID : UUID
  let ownerID : UUID
  let handle : String
  let lang : String
  let location : String
  let timezone : String
  let rank : Int
  let score : Int
  let numScore : Int
  let metadata : Data
  let rankedAt : Int
  let updatedAt : Int
  let expiresAt : Int
  
  internal init(from proto: Server_LeaderboardRecord) {
    leaderboardID = NakamaId.convert(data: proto.leaderboardID)
    ownerID = NakamaId.convert(data: proto.ownerID)
    handle = proto.handle
    lang = proto.lang
    location = proto.location
    timezone = proto.timezone
    rank = Int(proto.rank)
    score = Int(proto.score)
    numScore = Int(proto.numScore)
    metadata = proto.metadata
    rankedAt = Int(proto.rankedAt)
    expiresAt = Int(proto.expiresAt)
    updatedAt = Int(proto.updatedAt)
  }
  
  public var description: String {
    return String(format: "(leaderboardID=%@,ownerID=%@,handle=%@,lang=%@,location=%@,timezone=%@,rank=%d,score=%d,numScore=%d,metadata=%@,rankedAt=%d,expiresAt=%d,updatedAt=%d)", leaderboardID.uuidString, ownerID.uuidString, handle, lang, location, timezone, rank, score, numScore, metadata.base64EncodedString(), rankedAt, expiresAt, updatedAt)
  }
}



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

public protocol Leaderboard : CustomStringConvertible {
  /**
   - Returns: Leaderboard ID
   */
  var id : UUID { get }
  
  /**
   - Returns: Whether the client can submit scores or not
   */
  var authoritative : Bool { get }
  
  /**
   - Returns: Sort order used on the server
   */
  var sort : Int { get }
  
  /**
   - Returns: number of entries in the leaderboard
   */
  var count : Int { get }
  
  /**
   - Returns: The reset schedule in CRON format
   */
  var resetSchedule : String { get }
  
  /**
   - Returns: Metadata associated with the leaderboard
   */
  var metadata : Data { get }
  
  var nextID : UUID { get }
  
  var prevID : UUID { get }
}

internal struct DefaultLeaderboard : Leaderboard {
  let id : UUID
  let authoritative : Bool
  let sort : Int
  let count : Int
  let resetSchedule : String
  let metadata : Data
  let nextID : UUID
  let prevID : UUID
  
  internal init(from proto: Server_Leaderboard) {
    id = NakamaId.convert(data: proto.id)
    authoritative = proto.authoritative
    sort = Int(proto.sort)
    count = Int(proto.count)
    resetSchedule = proto.resetSchedule
    metadata = proto.metadata
    nextID = NakamaId.convert(data: proto.nextID)
    prevID = NakamaId.convert(data: proto.prevID)
  }
  
  public var description: String {
    return String(format: "DefaultLeaderboard(id=%@,authoritative=%@,sort=%d,count=%d,resetSchedule=%@,metadata=%@,nextID=%@,prevID=%@)", id.uuidString, authoritative.description, sort, count, resetSchedule, metadata.base64EncodedString(), nextID.uuidString, prevID.uuidString)
  }
}


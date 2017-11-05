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

public struct LeaderboardRecordsListMessage : CollatedMessage {
  private var ownerIds : [UUID]?
  private var ownerID : UUID?
  private var lang : String?
  private var location : String?
  private var timezone : String?

  public var leaderboardID : String
  public var limit: Int?
  public var cursor: String?
  
  /**
   This will unset other filters supplied
   */
  public var filterByLang : String? {
    set {
      lang = newValue
      location = nil
      timezone = nil
      ownerID = nil
      ownerIds = nil
    }
    get {
      return lang
    }
  }
  
  /**
   This will unset other filters supplied
   */
  public var filterByLocation: String? {
    set {
      lang = nil
      location = newValue
      timezone = nil
      ownerID = nil
      ownerIds = nil
    }
    get {
      return location
    }
  }
  
  /**
   This will unset other filters supplied
   */
  public var filterByTimezone: String? {
    set {
      lang = nil
      location = nil
      timezone = newValue
      ownerID = nil
      ownerIds = nil
    }
    get {
      return timezone
    }
  }
  
  /**
   This will unset other filters supplied
   */
  public var filterByPagingToOwnerID: UUID? {
    set {
      lang = nil
      location = nil
      timezone = nil
      ownerID = newValue
      ownerIds = nil
    }
    get {
      return ownerID
    }
  }
  
  /**
   This will unset other filters supplied
   */
  public var filterByOwnerIds: [UUID]? {
    set {
      lang = nil
      location = nil
      timezone = nil
      ownerID = nil
      ownerIds = newValue
    }
    get {
      return ownerIds
    }
  }
  
  
  public init(leaderboardID : String) {
    self.leaderboardID = leaderboardID
  }
  
  public func serialize(collationID: String) -> Data? {
    var listing = Server_TLeaderboardRecordsList()
    
    if let _limit = limit {
      listing.limit = Int64(_limit)
    }
    
    if let _cursor = cursor {
      listing.cursor = _cursor
    }
    
    if let _lang = lang {
      listing.lang = _lang
    }
    
    if let _location = location {
      listing.location = _location
    }
    
    if let _timezone = timezone {
      listing.timezone = _timezone
    }
    
    if let _ownerID = ownerID {
      listing.ownerID = NakamaId.convert(uuid: _ownerID)
    }
    
    if let _ownerIds = ownerIds {
      listing.ownerIds = Server_TLeaderboardRecordsList.Owners()
      
      for id in _ownerIds {
        listing.ownerIds.ownerIds.append(NakamaId.convert(uuid: id))
      }
    }
    
    var envelope = Server_Envelope()
    envelope.leaderboardRecordsList = listing
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "LeaderboardRecordsListMessage(leaderboardID=%@,limit=%d,filterByLang=%@,filterByLocation=%@,filterByTimezone=%@,filterByPagingToOwnerID=%@,filterByOwnerIds=%@,cursor=%@)", leaderboardID, limit ?? 0, filterByLang ?? "", filterByLocation ?? "", filterByTimezone ?? "", filterByPagingToOwnerID?.uuidString ?? "", filterByOwnerIds ?? "", cursor ?? "")
  }
  
}



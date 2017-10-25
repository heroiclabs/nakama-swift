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

public struct LeaderboardRecordWriteMessage : CollatedMessage {
  
  /**
   NOTE: The server only processes the first item of the list, and will ignore and logs a warning message for other items.
   */
  public var leaderboardRecords : [LeaderboardRecordWrite] = []
  
  public init() {}
  
  public func serialize(collationID: String) -> Data? {
    var proto = Server_TLeaderboardRecordsWrite()
    
    
    for record in leaderboardRecords {
      var w = Server_TLeaderboardRecordsWrite.LeaderboardRecordWrite()
      w.leaderboardID = NakamaId.convert(uuid: record.leaderboardID)
      
      if let _location = record.location {
        w.location = _location
      }
      
      if let _timezone = record.timezone {
        w.timezone = _timezone
      }
      
      if let _metadata = record.metadata {
        w.metadata = _metadata
      }
      
      if let _increment = record.increment {
        w.incr = Int64(_increment)
      }
      
      if let _decrement = record.decrement {
        w.decr = Int64(_decrement)
      }
      
      if let _set = record.set {
        w.set = Int64(_set)
      }
      
      if let _best = record.best {
        w.best = Int64(_best)
      }
      
      proto.records.append(w)
    }
    
    var envelope = Server_Envelope()
    envelope.leaderboardRecordsWrite = proto
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "LeaderboardRecordWriteMessage(leaderboardRecords=%@)", leaderboardRecords)
  }
}

public struct LeaderboardRecordWrite : CustomStringConvertible {
  public var leaderboardID : UUID
  public var location: String?
  public var timezone: String?
  public var metadata: Data?
  
  private var _increment : Int?
  private var _decrement : Int?
  private var _set : Int?
  private var _best : Int?
  
  /**
   This will unset other values supplied
   */
  public var increment : Int? {
    set {
      _increment = newValue
      _decrement = nil
      _set = nil
      _best = nil
    }
    get {
      return _increment
    }
  }
  
  /**
   This will unset other values supplied
   */
  public var set : Int? {
    set {
      _increment = nil
      _decrement = nil
      _set = newValue
      _best = nil
    }
    get {
      return _set
    }
  }
  
  /**
   This will unset other values supplied
   */
  public var decrement : Int? {
    set {
      _increment = nil
      _decrement = newValue
      _set = nil
      _best = nil
    }
    get {
      return _decrement
    }
  }
  
  /**
   This will unset other values supplied
   */
  public var best : Int? {
    set {
      _increment = nil
      _decrement = nil
      _set = nil
      _best = newValue
    }
    get {
      return _best
    }
  }
  
  public init(leaderboardID : UUID) {
    self.leaderboardID = leaderboardID
  }
  
  public var description: String {
    return String(format: "LeaderboardRecordWrite(leaderboardID=%@,location=%@,timezone=%@,metadata=%@,increment=%d,decrement=%d,set=%d,best=%d)", leaderboardID.uuidString, location ?? "", timezone ?? "", metadata?.base64EncodedString() ?? "", increment ?? 0, decrement ?? 0, set ?? 0, best ?? 0)
  }
}

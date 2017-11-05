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

public struct GroupsListMessage : CollatedMessage {
  
  private var lang : String?
  private var createdAt : Int?
  private var count : Int?
  
  public var pageLimit: Int?
  public var orderAscending: Bool?
  public var cursor: String?
  
  /**
   This will unset other filters supplied
   */
  public var filterByLang : String? {
    set {
      lang = newValue
      createdAt = nil
      count = nil
    }
    get {
      return lang
    }
  }
  
  /**
   This will unset other filters supplied
   */
  public var filterByCreatedAt: Int? {
    set {
      lang = nil
      createdAt = newValue
      count = nil
    }
    get {
      return createdAt
    }
  }
  
  /**
   This will unset other filters supplied
   */
  public var filterByCount: Int? {
    set {
      lang = nil
      createdAt = nil
      count = newValue
    }
    get {
      return count
    }
  }
  
  public init(){}
  
  public func serialize(collationID: String) -> Data? {
    var listing = Server_TGroupsList()
    
    if let _pageLimit = pageLimit {
      listing.pageLimit = Int64(_pageLimit)
    }
    
    if let _orderAsc = orderAscending {
      listing.orderByAsc = _orderAsc
    }
    
    if let _cursor = cursor {
      listing.cursor = _cursor
    }
    
    if let _lang = lang {
      listing.lang = _lang
    }
    
    if let _createdAt = createdAt {
      listing.createdAt = Int64(_createdAt)
    }
    
    if let _count = count {
      listing.count = Int64(_count)
    }
    
    var envelope = Server_Envelope()
    envelope.groupsList = listing
    envelope.collationID = collationID
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    return String(format: "GroupsListMessage(pageLimit=%d,orderAscending=%@,filterByLang=%@,filterByCreatedAt=%d,filterByCount=%d,cursor=%@)", pageLimit ?? 0, orderAscending?.description ?? "", filterByLang ?? "", filterByCreatedAt ?? 0, filterByCount ?? 0, cursor ?? "")
  }
  
}


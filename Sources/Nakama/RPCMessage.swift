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

public struct RPCMessage : CollatedMessage {
  public var payload: Data?
  private let id: String
  
  public init(id: String) {
    self.id = id
  }
  
  public func serialize(collationID: String) -> Data? {
    var proto = Server_TRpc()
    proto.id = self.id
    if payload != nil {
      proto.payload = String(data: payload!, encoding: .utf8)!
    }
    
    var envelope = Server_Envelope()
    envelope.collationID = collationID
    envelope.rpc = proto
    
    return try! envelope.serializedData()
  }
  
  public var description: String {
    var _payload = ""
    if let p = payload {
      _payload = String(data: p, encoding: .utf8)!
    }
    
    return String(format: "RPCMessage(id=%@,payload=%@)", id, _payload)
  }
}

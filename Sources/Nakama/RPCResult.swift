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

public protocol RPCResult : CustomStringConvertible {
  /**
   - Returns: The Id of the RPC function which was registered in the server.
   */
  var id : String { get }
  
  /**
   - Returns: The payload result sent back from the function call. May be {@code null}.
   */
  var payload : Data? { get }
  
}

internal struct DefaultRPCResult : RPCResult {
  let id: String
  let payload : Data?
  
  internal init(from proto: Server_TRpc) {
    self.id = proto.id
    self.payload = proto.payload
  }
  
  public var description: String {
    return String(format: "DefaultRPCResult(id=%@,payload=%@)", id, payload?.base64EncodedString() ?? "nil")
  }
}

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

public class NakamaId2 {
  public static func convert(uuidBase64: String) -> UUID {
    let uuidData = Data(base64Encoded: base64urlToBase64(base64url: uuidBase64))
    return convert(data: uuidData!)
  }
  
  public static func convert(uuid: UUID) -> String {
    let uuidData : Data = convert(uuid: uuid)
    return base64ToBase64url(base64: uuidData.base64EncodedString())
  }
  
  public static func convert(data:Data) -> UUID {
    return data.withUnsafeBytes { bytes in
      return NSUUID.init(uuidBytes: bytes) as UUID
    }
  }

  public static func convert(uuid: UUID) -> Data {
    var id = uuid
    return withUnsafePointer(to: &id) {
      Data(bytes: $0, count: MemoryLayout.size(ofValue: id))
    }
  }
  
  fileprivate static func base64urlToBase64(base64url: String) -> String {
    var base64 = base64url
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    if base64.count % 4 != 0 {
      base64.append(String(repeating: "=", count: 4 - base64.count % 4))
    }
    return base64
  }
  
  fileprivate static func base64ToBase64url(base64: String) -> String {
    let base64url = base64
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
    return base64url
  }
}

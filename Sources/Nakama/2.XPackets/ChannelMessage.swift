/*
 * Copyright 2018 Heroic Labs
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

public enum ChannelMessageType : Int32, Codable {
  case unknown = -1
  case chat = 0
  case groupJoin = 1
  case groupAdd = 2
  case groupLeave = 3
  case groupKick = 4
  case groupPromoted = 5
  
  static func make(from code:Int32) -> ChannelMessageType {
    switch code {
    case 0:
      return .chat
    case 1:
      return .groupJoin
    case 2:
      return .groupAdd
    case 3:
      return .groupLeave
    case 4:
      return .groupKick
    case 5:
      return .groupPromoted
    default:
      return .unknown
    }
  }
}


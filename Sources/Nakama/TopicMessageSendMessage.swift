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

public struct TopicMessageSendMessage : CollatedMessage {
  public var topicId: TopicId
  public var data: Data

  public init(topicId: TopicId, data: Data) {
    self.topicId = topicId
    self.data = data
  }

  public func serialize(collationID: String) -> Data? {
    var proto = Server_TTopicMessageSend()

    var t = Server_TopicId()
    switch topicId {
    case .directMessage(let d):
      t.dm = d
    case .group(let d):
      t.groupID = d
    case .room(let d):
      t.room = d
    }

    proto.topic = t
    proto.data = String(data: data, encoding: .utf8)!

    var envelope = Server_Envelope()
    envelope.collationID = collationID
    envelope.topicMessageSend = proto

    return try! envelope.serializedData()
  }

  public var description: String {
    return String(format: "TopicMessageSendMessage(topicId=%@, data=%@)", topicId.description, String(data: data, encoding: .utf8)!)
  }
}

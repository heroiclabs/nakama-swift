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

import XCTest
import Nakama
import PromiseKit

class TopicTest: XCTestCase {
  private let deviceID : String = UUID.init().uuidString
  private let deviceID2 : String = UUID.init().uuidString
  private var client : Client = Builder.defaults(serverKey: "defaultkey")
  private var client2 : Client = Builder.defaults(serverKey: "defaultkey")
  private var session : Session?
  private var session2 : Session?
  
  override func setUp() {
    super.setUp()
    
    let exp = expectation(description: "Client connect")
    var message = AuthenticateMessage(device: self.deviceID)
    client.register(with: message).then { session -> Promise<Session> in
      return self.client.connect(to: session)
    }.then { session -> Promise<Session> in
      self.session = session
      message = AuthenticateMessage(device: self.deviceID2)
      return self.client2.register(with: message)
    }.then { session -> Promise<Session> in
      return self.client2.connect(to: session)
    }.then { session in
      self.session2 = session
      exp.fulfill()
    }.catch{ err in
      XCTAssert(false, "Registration failed: " + (err as! NakamaError).message)
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  override func tearDown() {
    client.disconnect()
    client2.disconnect()
    super.tearDown()
  }
  
  func testTopicJoinSendReceiveListLeave() {
    let exp = expectation(description: "Topic message join, send, list and leave")
    let exp2 = expectation(description: "Topic message receive")
    
    client2.onTopicMessage = { topicMessage in
      XCTAssert(topicMessage.handle == self.session!.handle, "Incoming topic message handle was unexpected")
      exp2.fulfill()
    }
    
    var topic : TopicId?
    
    var message = TopicJoinMessage()
    message.userIds.append(session!.userID)
    client2.send(message: message).then { topics -> Promise<[Topic]> in
      var msg = TopicJoinMessage()
      msg.userIds.append(self.session2!.userID)
      return self.client.send(message: msg)
    }.then { topics -> Promise<TopicMessageAck> in
      topic = topics[0].topicId
      let msg = TopicMessageSendMessage(topicId: topic!, data: "{\"hello\":\"world\"}".data(using: String.Encoding.utf8)!)
      return self.client.send(message: msg)
    }.then { messageAck -> Promise<[TopicMessage]> in
      XCTAssert(messageAck.handle == self.session!.handle, "Message ack handle was unexpected")
      let msg = TopicMessagesListMessage(userID: self.session2!.userID)
      return self.client.send(message: msg)
    }.then { messages -> Promise<Void> in
      XCTAssert(messages.capacity == 1, "Messages received were more than expected count")
      XCTAssert(messages[0].handle == self.session!.handle, "Incoming topic message handle was unexpected")
      var msg = TopicLeaveMessage()
      msg.topics.append(topic!)
      return self.client.send(message: msg)
    }.catch { err in
      XCTAssert(false, "Fail to topic message join, send, receive, list and leave: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
}


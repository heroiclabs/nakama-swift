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

class NotificationTest: XCTestCase {
  private let deviceID : String = UUID.init().uuidString
  private let client : Client = Builder.defaults(serverKey: "defaultkey")
  private var session : Session?
  
  override func setUp() {
    super.setUp()
    
    let exp = expectation(description: "Client connect")
    let message = AuthenticateMessage(device: self.deviceID)
    client.register(with: message).then { session -> Promise<Session> in
      return self.client.connect(to: session)
    }.then { session -> Void in
      self.session = session
      let rpcMessage = RPCMessage(id: "notification_send")
      _ = self.client.send(message: rpcMessage)
    }.then {
      exp.fulfill()
    }.catch{ err in
      XCTAssert(false, "Registration failed: " + (err as! NakamaError).message)
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  override func tearDown() {
    client.disconnect()
    super.tearDown()
  }
  
  func testNotificationListAndRemove() {
    let exp = expectation(description: "Notification list")
    let message = NotificationListMessage(limit: 10)
    client.send(message: message).then { notifications -> Promise<Void> in
      XCTAssert(notifications.count > 0, "Failed to list notifications")
      var removeMessage = NotificationRemoveMessage()
      removeMessage.notificationIds.append(notifications[0].id)
      return self.client.send(message: removeMessage)
    }.catch { err in
      XCTAssert(false, "Notification list/remove failed: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
}


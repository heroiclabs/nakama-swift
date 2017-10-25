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

class FriendTest: XCTestCase {
  private let deviceID : String = UUID.init().uuidString
  private let deviceID2 : String = UUID.init().uuidString
  private let client : Client = Builder.defaults(serverKey: "defaultkey")
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
      return self.client.register(with: message)
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
    super.tearDown()
  }
  
  func testFriendAdd() {
    let exp = expectation(description: "Friend add")
    var message = FriendAddMessage()
    message.handles.append(self.session2!.handle)
    client.send(message: message).catch { err in
      XCTAssert(false, "Friend add failed: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  func testFriendList() {
    let exp = expectation(description: "Friend list")
    
    var message = FriendAddMessage()
    message.handles.append(self.session2!.handle)
    client.send(message: message).then {
      return self.client.send(message: FriendsListMessage())
    }.then { friends in
      XCTAssert(friends[0].handle == self.session2!.handle, "friends do not match")
      XCTAssert(friends[0].state == FriendState.invited, "Friend state is not invited")
    }.catch{err in
      XCTAssert(false, "Friend list failed: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  func testFriendBlock() {
    let exp = expectation(description: "Friend block")
    
    var message = FriendAddMessage()
    message.handles.append(self.session2!.handle)
    client.send(message: message).then { _ -> Promise<Void> in
      var message2 = FriendBlockMessage()
      message2.userIDs.append(self.session2!.userID)
      return self.client.send(message: message2)
    }.catch{err in
      XCTAssert(false, "Friend block failed: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  func testFriendRemove() {
    let exp = expectation(description: "Friend remove")
    
    var message = FriendAddMessage()
    message.handles.append(self.session2!.handle)
    client.send(message: message).then { _ -> Promise<Void> in
      var message2 = FriendRemoveMessage()
      message2.userIDs.append(self.session2!.userID)
      return self.client.send(message: message2)
      }.catch{err in
        XCTAssert(false, "Friend remove failed: " + (err as! NakamaError).message)
      }.always {
        exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
}

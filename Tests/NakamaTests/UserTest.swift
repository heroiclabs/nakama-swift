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

class SelfUserTest: XCTestCase {
  private let deviceID : String = UUID.init().uuidString
  private let client : Client = Builder.defaults(serverKey: "defaultkey")
  private var session : Session?
  
  override func setUp() {
    super.setUp()
    
    let exp = expectation(description: "Client connect")
    let message = AuthenticateMessage(device: self.deviceID)
    client.register(with: message).then { session in
      self.client.connect(to: session)
    }.then { session in
      self.session = session
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
  
  func testUsersFetch() {
    let exp = expectation(description: "Users Fetch")
    var message = UsersFetchMessage()
    message.handles.append(self.session!.handle)
    message.userIDs.append(self.session!.id)
    client.send(message: message).then { users in
      XCTAssert(users[0].id == self.session!.id, "user ID does not match")
      }.catch{err in
        XCTAssert(false, "Users fetch failed: " + (err as! NakamaError).message)
      }.always {
        exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  func testSelfFetch() {
    let exp = expectation(description: "Self Fetch")
    let message = SelfFetchMessage()
    client.send(message: message).then { selfuser in
      XCTAssert(selfuser.deviceIDs[0] == self.deviceID, "device IDs do not match")
      XCTAssert(!selfuser.handle.isEmpty, "handle is not set")
      XCTAssert(!selfuser.id.uuidString.isEmpty, "user id is not set")
    }.catch{err in
      XCTAssert(false, "Self fetch failed: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  func testSelfUpdate() {
    let exp = expectation(description: "Self Update")
    let epoch = Date().timeIntervalSince1970.description
    
    var message = SelfUpdateMessage()
    message.handle = "h-" + epoch
    
    client.send(message: message).then {
      return self.client.send(message: SelfFetchMessage())
    }.then { selfuser in
      XCTAssert(selfuser.handle == ("h-" + epoch), "handle is not updated correctly")
    }.catch{err in
      XCTAssert(false, "Self update failed: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  func testSelfLinkUnlink() {
    let exp = expectation(description: "Self Link")
    
    let uuid = UUID.init().uuidString
    let message = SelfLinkMessage(custom: uuid)
    client.send(message: message).then {
      return self.client.send(message: SelfFetchMessage())
    }.then { selfuser in
      XCTAssert(selfuser.customID == uuid, "Custom ID does not match")
      return self.client.send(message: SelfUnlinkMessage(device: self.deviceID))
    }.then {
      return self.client.send(message: SelfFetchMessage())
    }.then { selfuser in
      XCTAssert(selfuser.deviceIDs.isEmpty, "Device ID does not match")
    }.catch{err in
      XCTAssert(false, "Self link failed: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }

}

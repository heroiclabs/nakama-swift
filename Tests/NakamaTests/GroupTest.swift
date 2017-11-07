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

class GroupTest: XCTestCase {
  private let deviceID : String = UUID.init().uuidString
  private var client : Client = Builder.defaults(serverKey: "defaultkey")
  private var session : Session?
  
  override func setUp() {
    super.setUp()
    
    let exp = expectation(description: "Client connect")
    let message = AuthenticateMessage(device: self.deviceID)
    client.register(with: message).then { session -> Promise<Session> in
      return self.client.connect(to: session)
    }.then { session in
      self.session = session
      exp.fulfill()
    }.catch { err in
      XCTAssert(false, "Registration failed: " + (err as! NakamaError).message)
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  override func tearDown() {
    client.disconnect()
    super.tearDown()
  }
  
  func testTopicJoinSendReceiveListLeave() {
    let exp = expectation(description: "Topic message create, list, update, selfList, remove")
    
    var message = GroupCreateMessage()
    var gc = GroupCreate(name: "test-group")
    gc.desc = "test-group"
    gc.lang = "klingon"
    message.groupsCreate.append(gc)
    
    client.send(message: message).then { groups -> Promise<[Group]> in
      XCTAssert(groups.count == 1, "Failed to create group")
      var msg = GroupsListMessage()
      msg.filterByLang = "klingon"
      return self.client.send(message: msg)
    }.then { groups -> Promise<Void> in
      XCTAssert(groups.count > 0, "Failed to list groups")
      XCTAssert(groups[0].name == "test-group", "Group name did not match expected value")
      XCTAssert(groups[0].creatorID == self.session!.userID, "Group creator ID did not match the current user's ID")

      var gu = GroupUpdate(groupID: groups[0].id)
      gu.name = "test-group-update"
      
      var msg = GroupUpdateMessage()
      msg.groupsUpdate.append(gu)
      return self.client.send(message: msg)
    }.then { _ -> Promise<[GroupSelf]> in
      return self.client.send(message: GroupsSelfListMessage())
    }.then { groupsSelf -> Promise<Void> in
      XCTAssert(groupsSelf.count == 1, "Failed to list groups")
      XCTAssert(groupsSelf[0].name == "test-group-update", "Group name did not match expected value")
      
      var msg = GroupRemoveMessage()
      msg.groupIds.append(groupsSelf[0].id)
      return self.client.send(message: msg)
    }.catch { err in
      XCTAssert(false, "Topic message create, list, update, selfList, remove: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
}



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

class StorageTest: XCTestCase {
  private let deviceID : String = UUID.init().uuidString
  private let client : Client = Builder.defaults(serverKey: "defaultkey")
  private var session : Session?
  
  override func setUp() {
    super.setUp()
    
    let exp = expectation(description: "Client connect")
    let message = AuthenticateMessage(device: deviceID)
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
  
  func testStorage_1_Write_List_Remove() {
    let exp = expectation(description: "Storage write")
    let json = "{\"coins\": 100, \"gems\": 10, \"artifacts\": 0}"
    let value = json.data(using: .utf8)!
    
    let bucket = "bucket"
    let collection = "collection"
    let key = "key"

    var message = StorageWriteMessage()
    message.write(bucket: bucket, collection: collection, key: key, value: value)
    client.send(message: message).then { results -> Promise<[StorageRecord]> in
      let result = results[0]
      XCTAssert(result.bucket == bucket, "Storage bucket does not match")
      
      //list
      var message = StorageListMessage(bucket: bucket)
      message.collection = collection
      message.userID = self.session!.userID
      return self.client.send(message: message)
    }.then{ results -> Promise<Void> in
      let result = results[0]
      XCTAssert(result.value == json, "Storage value does not match")
      
      //remove
      var message = StorageRemoveMessage()
      message.remove(bucket: bucket, collection: collection, key: key)
      return self.client.send(message: message)
    }.catch{ err in
      XCTAssert(false, "Storage test failed: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 30, handler: nil)
  }
  
  
  func testStorage_2_Update_Fetch() {
    let exp = expectation(description: "Storage update")
    let json = "{\"coins\": 100, \"gems\": 10, \"artifacts\": 0}"
    let value = json.data(using: .utf8)!
    
    let ops = [
      StorageOp(init_: "/foo", value: value),
      StorageOp(incr: "/foo/coins", value: -10)
    ]
    
    var message = StorageUpdateMessage()
    message.update(bucket: "bucket", collection: "collection", key: "key", ops: ops, readPermission: PermissionRead.ownerRead, writePermission: PermissionWrite.ownerWrite)
    client.send(message: message).then { results -> Promise<[StorageRecord]> in
      let result = results[0]
      XCTAssert(result.bucket == "bucket", "Storage bucket does not match")
      
      //fetch
      var message = StorageFetchMessage()
      message.fetch(bucket: "bucket", collection: "collection", key: "key", userID: self.session!.userID)
      return self.client.send(message: message)
    }.then { results -> Promise<Void> in
      let result = results[0]

      let decoded = try JSONSerialization.jsonObject(with: result.value.data(using: .utf8)!, options: [])
      if let dictFromJSON = decoded as? [String:Any] {
        let obj = dictFromJSON["foo"] as! [String:Any]
        XCTAssert(obj["coins"] as! Int == 90, "Storage value does not match")
      } else {
        XCTAssert(false, "Storage value does not match")
      }

      //remove
      var message = StorageRemoveMessage()
      message.remove(bucket: "bucket", collection: "collection", key: "key")
      return self.client.send(message: message)
    }.catch{err in
      XCTAssert(false, "Storage update failed: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
}

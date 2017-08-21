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

class AuthenticationTest: XCTestCase {
  private let client : Client = Builder.defaults(serverKey: "defaultkey")
  private let deviceID : String = UUID.init().uuidString
    
  func testDeviceIdRegistration() {
    let exp = expectation(description: "Device registration")
    let message = AuthenticateMessage(device: deviceID)
    client.register(with: message).then { session in
      XCTAssert(!session.id.uuidString.isEmpty, "User ID is not set")
    }.catch{err in
      XCTAssert(false, "Registration failed: " + (err as! NakamaError).message)
    }.always {
      exp.fulfill()
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
  func testEmailRegistrationAndLogin() {
    let exp = expectation(description: "Email registration and login")
    
    let message = AuthenticateMessage(email: "test@example.com", password: "strongpassword")
    client.register(with: message).then { _ in
      return self.client.login(with: message)
    }.then { session in
      XCTAssert(!session.id.uuidString.isEmpty, "User ID is not set")
      exp.fulfill()
    }.catch { err in
      switch err as! NakamaError {
      case .userRegisterInuse(_):
        break;
      default:
        XCTAssert(false, "Registration failed: " + (err as! NakamaError).message)
        return
      }
      
      self.client.login(with: message).then { session in
          XCTAssert(!session.id.uuidString.isEmpty, "User ID is not set")
      }.catch { err in
        XCTAssert(false, "Registration failed: " + (err as! NakamaError).message)
      }.always {
          exp.fulfill()
      }
    }
    
    waitForExpectations(timeout: 10, handler: nil)
  }
  
}

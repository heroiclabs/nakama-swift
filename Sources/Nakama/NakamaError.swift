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

/**
  An error that has occured on the server.
  The error could be result of bad input, or unexpected system error.
  Check Error Code for more info.
 */
public enum NakamaError: Error {
  public static let Domain = "Nakama"
  /**
   An unknown error.
   */
  case unknown
  
  /**
   An unexpected error that is unrecoverable.
   */
  case runtimeException(String)
  
  /**
   Server received a message that is not recognized.
   */
  case unrecognizedPayload(String)
  
  /**
   Server received an Envelop message but the internal message is unrecognised. Most likely a protocol mismatch.
   */
  case missingPayload(String)
  
  /**
   The message did not include the required data in the correct format.
   */
  case badInput(String)
  
  /**
   Authentication failure.
   */
  case authError(String)
  
  /**
   Login failed because ID/device/email did not exist.
   */
  case userNotFound(String)
  
  /**
   Registration failed because ID/device/email exists.
   */
  case userRegisterInuse(String)
  
  /**
   Linking operation failed because link exists.
   */
  case userLinkInuse(String)
  
  /**
   Linking operation failed because third-party service was unreachable.
   */
  case userLinkProviderUnavailable(String)
  
  /**
   Unlinking operation failed because you cannot unlink last ID.
   */
  case userUnlinkDisallowed(String)
  
  /**
   Handle is in-use by another user.
   */
  case userHandleInuse(String)
  
  /**
   Group names must be unique and it's already in use.
   */
  case groupNameInuse(String)
  
  /**
   Group leave operation not allowed because the user is the last admin.
   */
  case groupLastAdmin(String)
  
  /**
   Storage write operation failed.
   */
  case storageRejected(String)
  
  /**
   Match with given ID was not found in the system.
   */
  case matchNotFound(String)
  
  /**
   Runtime function name was not found in system registry.
   */
  case runtimeFunctionNotFound(String)
  
  /**
   Runtime function caused an internal server error and did not complete.
   */
  case runtimeFunctionException(String)
  
  /**
   Message associated with the error
   */
  public var message : String {
    switch self {
    case .unknown:
      return ""
    case .runtimeException(let msg),
         .unrecognizedPayload(let msg),
         .missingPayload(let msg),
         .badInput(let msg),
         .authError(let msg),
         .userNotFound(let msg),
         .userRegisterInuse(let msg),
         .userLinkInuse(let msg),
         .userLinkProviderUnavailable(let msg),
         .userUnlinkDisallowed(let msg),
         .userHandleInuse(let msg),
         .groupNameInuse(let msg),
         .groupLastAdmin(let msg),
         .storageRejected(let msg),
         .matchNotFound(let msg),
         .runtimeFunctionNotFound(let msg),
         .runtimeFunctionException(let msg):
      return msg
    }
  }
  
  internal static func make(from code:Int32, msg:String) -> NakamaError {
    switch code {
    case 0:
      return .runtimeException(msg)
    case 1:
      return .unrecognizedPayload(msg)
    case 2:
      return .missingPayload(msg)
    case 3:
      return .badInput(msg)
    case 4:
      return .authError(msg)
    case 5:
      return .userNotFound(msg)
    case 6:
      return .userRegisterInuse(msg)
    case 7:
      return .userLinkInuse(msg)
    case 8:
      return .userLinkProviderUnavailable(msg)
    case 9:
      return .userUnlinkDisallowed(msg)
    case 10:
      return .userHandleInuse(msg)
    case 11:
      return .groupNameInuse(msg)
    case 12:
      return .groupLastAdmin(msg)
    case 13:
      return .storageRejected(msg)
    case 14:
      return .matchNotFound(msg)
    case 15:
      return .runtimeFunctionNotFound(msg)
    case 16:
      return .runtimeFunctionException(msg)
    default:
      return .unknown
    }
  }
}

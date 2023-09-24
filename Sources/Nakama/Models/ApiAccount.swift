/*
 * Copyright © 2023 Heroic Labs
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

/// A user with additional account details. Always the current user.
public struct ApiAccount {
    /// The user object.
    let user: ApiUser
    
    /// The custom id in the user's account.
    let customId: String
    
    /// The devices which belong to the user's account.
    let devices: [Nakama_Api_AccountDevice]
    
    /// The UNIX time when the user's account was disabled/banned.
    let disableTime: Date
    
    /// The email address of the user.
    let email: String
    
    /// The UNIX time when the user's email was verified.
    let VerifyTime: Date
    
    /// The user's wallet data.
    let wallet: String
}

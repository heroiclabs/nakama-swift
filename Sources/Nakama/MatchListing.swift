/*
 * Copyright 2018 Heroic Labs
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


public protocol MatchListing: Codable {
    var matches:[MatchFromServer] {get}
}

public struct MatchFromServer: Codable {
    let matchID: String
    let  label: String
    let isAuthoritative: Bool
}

public struct DefaultMatchListing: MatchListing {
    public var matches = [MatchFromServer]()
    internal init(response: Nakama_Api_MatchList){
        for m in response.matches {
            let match = MatchFromServer(matchID: m.matchID, label: m.label.value, isAuthoritative: m.authoritative)
            matches.append(match)
        }
        
    }
}


public struct User: Codable{
    let hasCreateTime: Bool
}
public struct DefaultUsers: Codable {
    var users: [User]
    
    internal init (rsp: Nakama_Api_Users){
        users = [User]()
        for user in rsp.users{
            let u = User(hasCreateTime: user.hasCreateTime)
            users.append(u)
        }
    }
}
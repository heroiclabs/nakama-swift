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

/// Incoming information about a party.
public struct Party {
    /// The unique party identifier.
    let id: String
    
    /// If the party is open to join.
    let open: Bool
    
    /// The maximum number of party members.
    let maxSize: Int
    
    /// The current user in this party. i.e. Yourself.
    let self_p: UserPresence
    
    /// The current party leader.
    let leader: UserPresence
    
    /// All members currently in the party.
    var presences: [UserPresence]
    
    /// Apply the joins and leaves from a presence event to the presences tracked by the party.
    mutating func updatePresences(event: PartyPresenceEvent) {
        guard event.partyId == self.id else {
            return
        }
        
        // Append joins and leaves
        self.presences.copyJoinsAndLeaves(joins: event.joins, leaves: event.leaves)
    }
}

public struct PartyPresenceEvent
{
    /// The ID of the party.
    let partyId: String
    
    /// The user presences that have just joined the party.
    let joins: [UserPresence]
    
    /// The user presences that have just left the party.
    let leaves: [UserPresence]
}

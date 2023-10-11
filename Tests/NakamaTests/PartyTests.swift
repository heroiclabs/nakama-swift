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

import XCTest
@testable import Nakama

final class PartyTests: XCTestCase {
    let client = GrpcClient(serverKey: "defaultkey")
    var session: Session!
    
    override func setUp() async throws {
        session = try await client.authenticateCustom(id: UUID().uuidString)
    }
    
    func test01_createJoinLeaveCloseParty() async throws {
        let socket = client.createSocket() as! Socket
        let socket2 = client.createSocket() as! Socket
        
        let session2 = try await client.authenticateCustom(id: UUID().uuidString)
        socket.connect(session: session)
        socket2.connect(session: session2)
        
        // Create
        let createdParty = try await socket.createParty(open: true, maxSize: 2)
        XCTAssertNotNil(createdParty)
        
        // Join
        var received: Party!
        socket2.onPartyReceived = { party in
            received = party
        }
        try await socket2.joinParty(partyId: createdParty.partyID)
        sleep(1)
        
        // Received join event
        XCTAssertNotNil(received)
        XCTAssertNotNil(received.self_p)
        XCTAssertEqual(received.self_p.userId, session2.userId)
        XCTAssertEqual(received.self_p.username, session2.username)
        
        // Leave
        var leave: UserPresence!
        socket.onPartyPresence = { presence in
            leave = presence.leaves.first?.toUserPresence()
        }
        try await socket2.leaveParty(partyId: createdParty.partyID)
        sleep(1)
        
        XCTAssertNotNil(leave)
        XCTAssertEqual(leave.userId, session2.userId)
        
        // Close
        var partyClose: Nakama_Realtime_PartyClose!
        socket.onPartyClosed = { close in
            partyClose = close
        }
        try await socket.closeParty(partyId: createdParty.partyID)
        sleep(1)
        
        XCTAssertNotNil(partyClose)
        XCTAssertEqual(partyClose.partyID, createdParty.partyID)
    }
    
    func test02_partyFullJoinAttempt() async throws {
        let socket = client.createSocket() as! Socket
        let socket2 = client.createSocket() as! Socket
        let socket3 = client.createSocket() as! Socket
        
        let session2 = try await client.authenticateCustom(id: UUID().uuidString)
        let session3 = try await client.authenticateCustom(id: UUID().uuidString)
        socket.connect(session: session)
        socket2.connect(session: session2)
        socket3.connect(session: session3)
        
        let party = try await socket.createParty(open: true, maxSize: 2)
        XCTAssertNotNil(party)
        
        try await socket2.joinParty(partyId: party.partyID)
        
        do {
            try await socket3.joinParty(partyId: party.partyID)
            XCTFail("Should not join full party")
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func test03_initialPresenceIsTheLeader() async throws {
        let socket = client.createSocket() as! Socket
        socket.connect(session: session)
        
        let party = try await socket.createParty(open: true, maxSize: 2)
        XCTAssertNotNil(party)
        
        // Initial presence is leader
        XCTAssertEqual(party.presences.count, 1)
        XCTAssertEqual(party.presences.first, party.leader)
    }
    
    func test04_partyMatchmakerAddRemove() async throws {
        let socket = client.createSocket() as! Socket
        let socket2 = client.createSocket() as! Socket
        
        let session2 = try await client.authenticateCustom(id: UUID().uuidString)
        
        socket.connect(session: session)
        socket2.connect(session: session2)
        
        let party = try await socket.createParty(open: true, maxSize: 2)
        XCTAssertNotNil(party)
        
        try await socket2.joinParty(partyId: party.partyID)
        sleep(1)
        
        // Add
        let partyTicket = try await socket.addMatchmakerParty(partyId: party.partyID, query: "*", minCount: 2, maxCount: 2)
        XCTAssertNotNil(partyTicket)
        XCTAssertNotEqual(partyTicket.ticket, "")
        
        // Remove
        do {
            try await socket.removeMatchmakerParty(partyId: party.partyID, ticket: partyTicket.ticket)
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }

        // Close
        var partyClose: Nakama_Realtime_PartyClose!
        socket.onPartyClosed = { close in
            partyClose = close
        }
        try await socket.closeParty(partyId: party.partyID)
        sleep(1)
        
        XCTAssertNotNil(partyClose)
        XCTAssertEqual(partyClose.partyID, party.partyID)
    }
}

/*
 * Copyright © 2026 The Nakama Authors
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

/// Channel types accepted by `joinChat`.
public enum ChannelType: Int, Sendable {
    case room = 1
    case directMessage = 2
    case group = 3
}

/// The realtime API. Requests are correlated to their replies by `cid`; anything the
/// server pushes unprompted arrives on the matching handler.
public protocol SocketProtocol: AnyObject {
    var isConnected: Bool { get }

    // MARK: Lifecycle

    func connect(session: Session, appearOnline: Bool, lang: String) async throws
    func disconnect() async

    /// Round trip an application-level heartbeat.
    func ping() async throws

    // MARK: Chat

    func joinChat(target: String, type: ChannelType, persistence: Bool?, hidden: Bool?) async throws -> NakamaRealtimeChannel
    func leaveChat(channelId: String) async throws
    func writeChatMessage(channelId: String, content: String) async throws -> NakamaRealtimeChannelMessageAck
    func updateChatMessage(channelId: String, messageId: String, content: String) async throws -> NakamaRealtimeChannelMessageAck
    func removeChatMessage(channelId: String, messageId: String) async throws -> NakamaRealtimeChannelMessageAck

    // MARK: Matches

    func createMatch(name: String) async throws -> NakamaRealtimeMatch
    func joinMatch(matchId: String, metadata: [String: String]) async throws -> NakamaRealtimeMatch
    func joinMatchByToken(token: String, metadata: [String: String]) async throws -> NakamaRealtimeMatch
    func leaveMatch(matchId: String) async throws
    func sendMatchData(matchId: String, opCode: Int, data: Data, presences: [NakamaRealtimeUserPresence], reliable: Bool) async throws

    // MARK: Matchmaker

    func addMatchmaker(minCount: Int, maxCount: Int, query: String, countMultiple: Int?, stringProperties: [String: String], numericProperties: [String: Double]) async throws -> NakamaRealtimeMatchmakerTicket
    func removeMatchmaker(ticket: String) async throws

    // MARK: Status

    func followUsers(userIds: [String], usernames: [String]) async throws -> NakamaRealtimeStatus
    func unfollowUsers(userIds: [String]) async throws
    func updateStatus(_ status: String?) async throws

    // MARK: Parties

    func createParty(open: Bool, maxSize: Int) async throws -> NakamaRealtimeParty
    func joinParty(partyId: String) async throws
    func leaveParty(partyId: String) async throws
    func closeParty(partyId: String) async throws
    func promotePartyMember(partyId: String, presence: NakamaRealtimeUserPresence) async throws
    func acceptPartyMember(partyId: String, presence: NakamaRealtimeUserPresence) async throws
    func removePartyMember(partyId: String, presence: NakamaRealtimeUserPresence) async throws
    func listPartyJoinRequests(partyId: String) async throws -> NakamaRealtimePartyJoinRequest
    func addPartyMatchmaker(partyId: String, minCount: Int, maxCount: Int, query: String, countMultiple: Int?, stringProperties: [String: String], numericProperties: [String: Double]) async throws -> NakamaRealtimePartyMatchmakerTicket
    func removePartyMatchmaker(partyId: String, ticket: String) async throws
    func sendPartyData(partyId: String, opCode: Int, data: Data) async throws

    // MARK: Rpc

    func rpc(id: String, payload: String) async throws -> NakamaRpc

    // MARK: Handlers

    /// Called when the connection closes, with the underlying error when it was not a
    /// clean shutdown.
    var onDisconnect: ((Error?) -> Void)? { get set }

    /// A server error that arrived without a `cid`, so it belongs to no request.
    var onError: ((NakamaRealtimeError) -> Void)? { get set }

    var onChannelMessage: ((NakamaChannelMessage) -> Void)? { get set }
    var onChannelPresence: ((NakamaRealtimeChannelPresenceEvent) -> Void)? { get set }
    var onMatchData: ((NakamaRealtimeMatchData) -> Void)? { get set }
    var onMatchPresence: ((NakamaRealtimeMatchPresenceEvent) -> Void)? { get set }
    var onMatchmakerMatched: ((NakamaRealtimeMatchmakerMatched) -> Void)? { get set }
    var onNotifications: ((NakamaRealtimeNotifications) -> Void)? { get set }
    var onStatusPresence: ((NakamaRealtimeStatusPresenceEvent) -> Void)? { get set }
    var onStreamData: ((NakamaRealtimeStreamData) -> Void)? { get set }
    var onStreamPresence: ((NakamaRealtimeStreamPresenceEvent) -> Void)? { get set }
    var onParty: ((NakamaRealtimeParty) -> Void)? { get set }
    var onPartyClose: ((NakamaRealtimePartyClose) -> Void)? { get set }
    var onPartyData: ((NakamaRealtimePartyData) -> Void)? { get set }
    var onPartyJoinRequest: ((NakamaRealtimePartyJoinRequest) -> Void)? { get set }
    var onPartyLeader: ((NakamaRealtimePartyLeader) -> Void)? { get set }
    var onPartyMatchmakerTicket: ((NakamaRealtimePartyMatchmakerTicket) -> Void)? { get set }
    var onPartyPresence: ((NakamaRealtimePartyPresenceEvent) -> Void)? { get set }
}

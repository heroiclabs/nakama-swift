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
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension NakamaRealtimeError: Error {}

public final class Socket: SocketProtocol, @unchecked Sendable {
    public private(set) var isConnected = false

    public var onDisconnect: ((Error?) -> Void)?
    public var onError: ((NakamaRealtimeError) -> Void)?
    public var onChannelMessage: ((NakamaChannelMessage) -> Void)?
    public var onChannelPresence: ((NakamaRealtimeChannelPresenceEvent) -> Void)?
    public var onMatchData: ((NakamaRealtimeMatchData) -> Void)?
    public var onMatchPresence: ((NakamaRealtimeMatchPresenceEvent) -> Void)?
    public var onMatchmakerMatched: ((NakamaRealtimeMatchmakerMatched) -> Void)?
    public var onNotifications: ((NakamaRealtimeNotifications) -> Void)?
    public var onStatusPresence: ((NakamaRealtimeStatusPresenceEvent) -> Void)?
    public var onStreamData: ((NakamaRealtimeStreamData) -> Void)?
    public var onStreamPresence: ((NakamaRealtimeStreamPresenceEvent) -> Void)?
    public var onParty: ((NakamaRealtimeParty) -> Void)?
    public var onPartyClose: ((NakamaRealtimePartyClose) -> Void)?
    public var onPartyData: ((NakamaRealtimePartyData) -> Void)?
    public var onPartyJoinRequest: ((NakamaRealtimePartyJoinRequest) -> Void)?
    public var onPartyLeader: ((NakamaRealtimePartyLeader) -> Void)?
    public var onPartyMatchmakerTicket: ((NakamaRealtimePartyMatchmakerTicket) -> Void)?
    public var onPartyPresence: ((NakamaRealtimePartyPresenceEvent) -> Void)?

    private let baseUri: URL
    private var task: URLSessionWebSocketTask?
    private var receiveLoop: Task<Void, Never>?
    private let pending = Pending()

    public init(scheme: String = "ws", host: String = "127.0.0.1", port: Int = 7350) throws {
        let uri = "\(scheme)://\(host):\(port)"
        guard let baseUri = URL(string: uri), baseUri.host != nil else {
            throw NakamaError.invalidServerUri(uri)
        }
        self.baseUri = baseUri
    }

    // MARK: - Lifecycle

    public func connect(session: Session, appearOnline: Bool = true, lang: String = "en") async throws {
        guard task == nil else { return }

        var components = URLComponents()
        // http/https are accepted for convenience so callers can pass the same scheme
        // they gave HttpClient.
        switch baseUri.scheme {
        case "https", "wss": components.scheme = "wss"
        default: components.scheme = "ws"
        }
        components.host = baseUri.host
        components.port = baseUri.port
        components.path = "/ws"
        components.queryItems = [
            URLQueryItem(name: "token", value: session.token),
            URLQueryItem(name: "status", value: appearOnline ? "true" : "false"),
            URLQueryItem(name: "lang", value: lang),
            URLQueryItem(name: "format", value: "json"),
        ]
        guard let url = components.url else {
            throw NakamaError.invalidServerUri(components.description)
        }

        let task = URLSession.shared.webSocketTask(with: url)
        self.task = task
        isConnected = true
        task.resume()
        startReceiveLoop(task)

        // The handshake result does not surface until the first read, so prove the
        // connection with a round trip. A rejected token fails here rather than later.
        do {
            try await ping()
        } catch {
            await disconnect()
            throw error
        }
    }

    public func disconnect() async {
        receiveLoop?.cancel()
        receiveLoop = nil
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        isConnected = false
        await pending.failAll(NakamaError.socketNotConnected)
    }

    public func ping() async throws {
        _ = try await send { $0.ping = NakamaRealtimePing() }
    }

    // MARK: - Chat

    public func joinChat(
        target: String,
        type: ChannelType,
        persistence: Bool? = nil,
        hidden: Bool? = nil
    ) async throws -> NakamaRealtimeChannel {
        try await send(\.channel) {
            $0.channelJoin = NakamaRealtimeChannelJoin(
                target: target, type: type.rawValue, persistence: persistence, hidden: hidden
            )
        }
    }

    public func leaveChat(channelId: String) async throws {
        _ = try await send { $0.channelLeave = NakamaRealtimeChannelLeave(channelId: channelId) }
    }

    public func writeChatMessage(channelId: String, content: String) async throws -> NakamaRealtimeChannelMessageAck {
        try await send(\.channelMessageAck) {
            $0.channelMessageSend = NakamaRealtimeChannelMessageSend(channelId: channelId, content: content)
        }
    }

    public func updateChatMessage(
        channelId: String,
        messageId: String,
        content: String
    ) async throws -> NakamaRealtimeChannelMessageAck {
        try await send(\.channelMessageAck) {
            $0.channelMessageUpdate = NakamaRealtimeChannelMessageUpdate(
                channelId: channelId, messageId: messageId, content: content
            )
        }
    }

    public func removeChatMessage(channelId: String, messageId: String) async throws -> NakamaRealtimeChannelMessageAck {
        try await send(\.channelMessageAck) {
            $0.channelMessageRemove = NakamaRealtimeChannelMessageRemove(
                channelId: channelId, messageId: messageId
            )
        }
    }

    // MARK: - Matches

    public func createMatch(name: String = "") async throws -> NakamaRealtimeMatch {
        try await send(\.match) { $0.matchCreate = NakamaRealtimeMatchCreate(name: name) }
    }

    public func joinMatch(matchId: String, metadata: [String: String] = [:]) async throws -> NakamaRealtimeMatch {
        try await send(\.match) {
            $0.matchJoin = NakamaRealtimeMatchJoin(matchId: matchId, metadata: metadata)
        }
    }

    public func joinMatchByToken(token: String, metadata: [String: String] = [:]) async throws -> NakamaRealtimeMatch {
        try await send(\.match) {
            $0.matchJoin = NakamaRealtimeMatchJoin(token: token, metadata: metadata)
        }
    }

    public func leaveMatch(matchId: String) async throws {
        _ = try await send { $0.matchLeave = NakamaRealtimeMatchLeave(matchId: matchId) }
    }

    public func sendMatchData(
        matchId: String,
        opCode: Int,
        data: Data,
        presences: [NakamaRealtimeUserPresence] = [],
        reliable: Bool = true
    ) async throws {
        _ = try await send {
            $0.matchDataSend = NakamaRealtimeMatchDataSend(
                matchId: matchId, opCode: opCode, data: data,
                presences: presences, reliable: reliable
            )
        }
    }

    // MARK: - Matchmaker

    public func addMatchmaker(
        minCount: Int,
        maxCount: Int,
        query: String = "*",
        countMultiple: Int? = nil,
        stringProperties: [String: String] = [:],
        numericProperties: [String: Double] = [:]
    ) async throws -> NakamaRealtimeMatchmakerTicket {
        try await send(\.matchmakerTicket) {
            $0.matchmakerAdd = NakamaRealtimeMatchmakerAdd(
                minCount: minCount, maxCount: maxCount, query: query,
                countMultiple: countMultiple, stringProperties: stringProperties,
                numericProperties: numericProperties
            )
        }
    }

    public func removeMatchmaker(ticket: String) async throws {
        _ = try await send { $0.matchmakerRemove = NakamaRealtimeMatchmakerRemove(ticket: ticket) }
    }

    // MARK: - Status

    public func followUsers(userIds: [String], usernames: [String] = []) async throws -> NakamaRealtimeStatus {
        try await send(\.status) {
            $0.statusFollow = NakamaRealtimeStatusFollow(userIds: userIds, usernames: usernames)
        }
    }

    public func unfollowUsers(userIds: [String]) async throws {
        _ = try await send { $0.statusUnfollow = NakamaRealtimeStatusUnfollow(userIds: userIds) }
    }

    public func updateStatus(_ status: String?) async throws {
        _ = try await send { $0.statusUpdate = NakamaRealtimeStatusUpdate(status: status) }
    }

    // MARK: - Parties

    public func createParty(open: Bool, maxSize: Int) async throws -> NakamaRealtimeParty {
        try await send(\.party) { $0.partyCreate = NakamaRealtimePartyCreate(open: open, maxSize: maxSize) }
    }

    public func joinParty(partyId: String) async throws {
        _ = try await send { $0.partyJoin = NakamaRealtimePartyJoin(partyId: partyId) }
    }

    public func leaveParty(partyId: String) async throws {
        _ = try await send { $0.partyLeave = NakamaRealtimePartyLeave(partyId: partyId) }
    }

    public func closeParty(partyId: String) async throws {
        _ = try await send { $0.partyClose = NakamaRealtimePartyClose(partyId: partyId) }
    }

    public func promotePartyMember(partyId: String, presence: NakamaRealtimeUserPresence) async throws {
        _ = try await send {
            $0.partyPromote = NakamaRealtimePartyPromote(partyId: partyId, presence: presence)
        }
    }

    public func acceptPartyMember(partyId: String, presence: NakamaRealtimeUserPresence) async throws {
        _ = try await send {
            $0.partyAccept = NakamaRealtimePartyAccept(partyId: partyId, presence: presence)
        }
    }

    public func removePartyMember(partyId: String, presence: NakamaRealtimeUserPresence) async throws {
        _ = try await send {
            $0.partyRemove = NakamaRealtimePartyRemove(partyId: partyId, presence: presence)
        }
    }

    public func listPartyJoinRequests(partyId: String) async throws -> NakamaRealtimePartyJoinRequest {
        try await send(\.partyJoinRequest) {
            $0.partyJoinRequestList = NakamaRealtimePartyJoinRequestList(partyId: partyId)
        }
    }

    public func addPartyMatchmaker(
        partyId: String,
        minCount: Int,
        maxCount: Int,
        query: String = "*",
        countMultiple: Int? = nil,
        stringProperties: [String: String] = [:],
        numericProperties: [String: Double] = [:]
    ) async throws -> NakamaRealtimePartyMatchmakerTicket {
        try await send(\.partyMatchmakerTicket) {
            $0.partyMatchmakerAdd = NakamaRealtimePartyMatchmakerAdd(
                partyId: partyId, minCount: minCount, maxCount: maxCount, query: query,
                countMultiple: countMultiple, stringProperties: stringProperties,
                numericProperties: numericProperties
            )
        }
    }

    public func removePartyMatchmaker(partyId: String, ticket: String) async throws {
        _ = try await send {
            $0.partyMatchmakerRemove = NakamaRealtimePartyMatchmakerRemove(partyId: partyId, ticket: ticket)
        }
    }

    public func sendPartyData(partyId: String, opCode: Int, data: Data) async throws {
        _ = try await send {
            $0.partyDataSend = NakamaRealtimePartyDataSend(partyId: partyId, opCode: opCode, data: data)
        }
    }

    // MARK: - Rpc

    public func rpc(id: String, payload: String = "") async throws -> NakamaRpc {
        try await send(\.rpc) { $0.rpc = NakamaRpc(id: id, payload: payload) }
    }

    // MARK: - Transport

    /// Send an envelope and return the field of the reply the caller asked for.
    private func send<T>(
        _ field: KeyPath<NakamaRealtimeEnvelope, T?>,
        _ build: (inout NakamaRealtimeEnvelope) -> Void
    ) async throws -> T {
        let reply = try await send(build)
        guard let value = reply[keyPath: field] else {
            throw NakamaError.unexpectedRealtimeReply
        }
        return value
    }

    @discardableResult
    private func send(_ build: (inout NakamaRealtimeEnvelope) -> Void) async throws -> NakamaRealtimeEnvelope {
        guard let task else { throw NakamaError.socketNotConnected }

        let cid = await pending.nextCid()
        var envelope = NakamaRealtimeEnvelope()
        envelope.cid = cid
        build(&envelope)
        let payload = try JSONEncoder().encode(envelope)

        return try await withCheckedThrowingContinuation { continuation in
            Task {
                // Register before sending: on a fast local server the reply can arrive
                // before this task would otherwise get to run.
                await pending.register(cid, continuation)
                task.send(.data(payload)) { error in
                    guard let error else { return }
                    Task { await self.pending.resume(cid, with: .failure(error)) }
                }
            }
        }
    }

    private func startReceiveLoop(_ task: URLSessionWebSocketTask) {
        receiveLoop = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    let message = try await Socket.receive(from: task)
                    guard let self else { return }
                    await self.dispatch(message)
                } catch {
                    guard let self, !Task.isCancelled else { return }
                    await self.tearDown(error)
                    return
                }
            }
        }
    }

    // URLSessionWebSocketTask.receive() as async is iOS 15 / macOS 12; this package
    // targets iOS 13.
    private static func receive(
        from task: URLSessionWebSocketTask
    ) async throws -> URLSessionWebSocketTask.Message {
        try await withCheckedThrowingContinuation { continuation in
            task.receive { continuation.resume(with: $0) }
        }
    }

    private func dispatch(_ message: URLSessionWebSocketTask.Message) async {
        let data: Data
        switch message {
        case .data(let payload): data = payload
        case .string(let text): data = Data(text.utf8)
        @unknown default: return
        }

        guard let envelope = try? JSONDecoder().decode(NakamaRealtimeEnvelope.self, from: data) else {
            return
        }

        guard envelope.cid.isEmpty else {
            if let error = envelope.error {
                await pending.resume(envelope.cid, with: .failure(error))
            } else {
                await pending.resume(envelope.cid, with: .success(envelope))
            }
            return
        }

        if let error = envelope.error { onError?(error) }
        if let value = envelope.channelMessage { onChannelMessage?(value) }
        if let value = envelope.channelPresenceEvent { onChannelPresence?(value) }
        if let value = envelope.matchData { onMatchData?(value) }
        if let value = envelope.matchPresenceEvent { onMatchPresence?(value) }
        if let value = envelope.matchmakerMatched { onMatchmakerMatched?(value) }
        if let value = envelope.notifications { onNotifications?(value) }
        if let value = envelope.statusPresenceEvent { onStatusPresence?(value) }
        if let value = envelope.streamData { onStreamData?(value) }
        if let value = envelope.streamPresenceEvent { onStreamPresence?(value) }
        if let value = envelope.party { onParty?(value) }
        if let value = envelope.partyClose { onPartyClose?(value) }
        if let value = envelope.partyData { onPartyData?(value) }
        if let value = envelope.partyJoinRequest { onPartyJoinRequest?(value) }
        if let value = envelope.partyLeader { onPartyLeader?(value) }
        if let value = envelope.partyMatchmakerTicket { onPartyMatchmakerTicket?(value) }
        if let value = envelope.partyPresenceEvent { onPartyPresence?(value) }
    }

    private func tearDown(_ error: Error?) async {
        task = nil
        isConnected = false
        receiveLoop = nil
        await pending.failAll(error ?? NakamaError.socketNotConnected)
        onDisconnect?(error)
    }
}

/// Hands out correlation ids and holds the continuation waiting on each one.
private actor Pending {
    private var counter = 0
    private var waiters: [String: CheckedContinuation<NakamaRealtimeEnvelope, Error>] = [:]

    func nextCid() -> String {
        counter += 1
        return String(counter)
    }

    func register(_ cid: String, _ continuation: CheckedContinuation<NakamaRealtimeEnvelope, Error>) {
        waiters[cid] = continuation
    }

    func resume(_ cid: String, with result: Result<NakamaRealtimeEnvelope, Error>) {
        waiters.removeValue(forKey: cid)?.resume(with: result)
    }

    func failAll(_ error: Error) {
        let outstanding = waiters
        waiters.removeAll()
        for continuation in outstanding.values {
            continuation.resume(throwing: error)
        }
    }
}

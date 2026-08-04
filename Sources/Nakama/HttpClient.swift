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

public final class HttpClient: NakamaClientProtocol {
    public let scheme: String
    public let host: String
    public let port: Int

    public var globalRetryConfiguration = RetryConfiguration(baseDelayMs: 500, maxRetries: 4)

    /// Per-request timeout in seconds.
    public var timeout: TimeInterval = 10

    private let baseUri: URL
    private let basicAuthCredentials: String
    private let retryInvoker: RetryInvoker
    private let refresher = SessionRefresher()

    public init(
        serverKey: String,
        scheme: String = "http",
        host: String = "127.0.0.1",
        port: Int = 7350
    ) throws {
        let uri = "\(scheme)://\(host):\(port)"
        guard let baseUri = URL(string: uri), baseUri.host != nil else {
            throw NakamaError.invalidServerUri(uri)
        }

        self.scheme = scheme
        self.host = host
        self.port = port
        self.baseUri = baseUri
        self.basicAuthCredentials = Data("\(serverKey):".utf8).base64EncodedString()
        self.retryInvoker = RetryInvoker(handler: { error in
            if let error = error as? ApiResponseError, let status = error.statusCode {
                return status == 500 || status == 502 || status == 503 || status == 504
            }
            return error is URLError
        })
    }

    // MARK: - Transport

    /// (Bearer) Send request, renew the session first when it is close to expiry.
    private func send<T: Decodable>(
        _ request: ApiRequest<T>,
        session: Session,
        _ retryConfig: RetryConfiguration?
    ) async throws -> T {
        try await refresher.refreshIfNeeded(session) { try await self.sessionRefresh(session: $0) }
        return try await retryInvoker.invokeWithRetry(
            request: { try await self.perform(request, authorization: "Bearer \(session.token)") },
            configuration: retryConfig ?? globalRetryConfiguration
        )
    }

    /// (Basic auth) For session endpoints.
    private func send<T: Decodable>(
        _ request: ApiRequest<T>,
        _ retryConfig: RetryConfiguration?
    ) async throws -> T {
        try await retryInvoker.invokeWithRetry(
            request: { try await self.perform(request, authorization: "Basic \(self.basicAuthCredentials)") },
            configuration: retryConfig ?? globalRetryConfiguration
        )
    }

    private func perform<T: Decodable>(_ request: ApiRequest<T>, authorization: String) async throws -> T {
        var urlRequest = URLRequest(url: try request.url(relativeTo: baseUri))
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = request.body
        urlRequest.timeoutInterval = timeout

        // URLSession.data(for:) needs iOS 15 / macOS 12; this package targets iOS 13.
        let (data, response): (Data, HTTPURLResponse) = try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let response = response as? HTTPURLResponse {
                    continuation.resume(returning: (data ?? Data(), response))
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }.resume()
        }

        guard (200..<300).contains(response.statusCode) else {
            guard let error = try? JSONDecoder().decode(ApiResponseError.self, from: data) else {
                throw NakamaError.unexpectedResponse(statusCode: response.statusCode)
            }
            error.statusCode = response.statusCode
            throw error
        }

        // Void endpoints answer with `{}`, but some also answer with nothing at all.
        if T.self == EmptyResponse.self, let empty = EmptyResponse() as? T {
            return empty
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Session

    public func authenticateApple(
        token: String,
        username: String = "",
        create: Bool? = nil,
        vars: [String: String] = [:],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> Session {
        try await session(from: ApiRequests.NakamaAuthenticateApple(
            create: create, username: username,
            body: NakamaAccountApple(token: token, vars: vars)
        ), retryConfig)
    }

    public func authenticateCustom(
        id: String,
        username: String = "",
        create: Bool? = nil,
        vars: [String: String] = [:],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> Session {
        try await session(from: ApiRequests.NakamaAuthenticateCustom(
            create: create, username: username,
            body: NakamaAccountCustom(id: id, vars: vars)
        ), retryConfig)
    }

    public func authenticateDevice(
        id: String,
        username: String = "",
        create: Bool? = nil,
        vars: [String: String] = [:],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> Session {
        try await session(from: ApiRequests.NakamaAuthenticateDevice(
            create: create, username: username,
            body: NakamaAccountDevice(id: id, vars: vars)
        ), retryConfig)
    }

    public func authenticateEmail(
        email: String,
        password: String,
        username: String = "",
        create: Bool? = nil,
        vars: [String: String] = [:],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> Session {
        try await session(from: ApiRequests.NakamaAuthenticateEmail(
            create: create, username: username,
            body: NakamaAccountEmail(email: email, password: password, vars: vars)
        ), retryConfig)
    }

    public func authenticateFacebook(
        token: String,
        username: String = "",
        create: Bool? = nil,
        sync: Bool? = nil,
        vars: [String: String] = [:],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> Session {
        try await session(from: ApiRequests.NakamaAuthenticateFacebook(
            create: create, username: username, sync: sync,
            body: NakamaAccountFacebook(token: token, vars: vars)
        ), retryConfig)
    }

    public func authenticateFacebookInstantGame(
        signedPlayerInfo: String,
        username: String = "",
        create: Bool? = nil,
        vars: [String: String] = [:],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> Session {
        try await session(from: ApiRequests.NakamaAuthenticateFacebookInstantGame(
            create: create, username: username,
            body: NakamaAccountFacebookInstantGame(signedPlayerInfo: signedPlayerInfo, vars: vars)
        ), retryConfig)
    }

    public func authenticateGameCenter(
        playerId: String,
        bundleId: String,
        timestampSeconds: Int,
        salt: String,
        signature: String,
        publicKeyUrl: String,
        username: String = "",
        create: Bool? = nil,
        vars: [String: String] = [:],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> Session {
        try await session(from: ApiRequests.NakamaAuthenticateGameCenter(
            create: create, username: username,
            body: NakamaAccountGameCenter(
                playerId: playerId, bundleId: bundleId, timestampSeconds: timestampSeconds,
                salt: salt, signature: signature, publicKeyUrl: publicKeyUrl, vars: vars
            )
        ), retryConfig)
    }

    public func authenticateGoogle(
        token: String,
        username: String = "",
        create: Bool? = nil,
        vars: [String: String] = [:],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> Session {
        try await session(from: ApiRequests.NakamaAuthenticateGoogle(
            create: create, username: username,
            body: NakamaAccountGoogle(token: token, vars: vars)
        ), retryConfig)
    }

    public func authenticateSteam(
        token: String,
        username: String = "",
        create: Bool? = nil,
        sync: Bool? = nil,
        vars: [String: String] = [:],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> Session {
        try await session(from: ApiRequests.NakamaAuthenticateSteam(
            create: create, username: username, sync: sync,
            body: NakamaAccountSteam(token: token, vars: vars)
        ), retryConfig)
    }

    public func sessionRefresh(
        session: Session,
        vars: [String: String] = [:],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> Session {
        let response = try await send(ApiRequests.NakamaSessionRefresh(
            body: NakamaSessionRefreshRequest(token: session.refreshToken, vars: vars)
        ), retryConfig)
        try session.update(token: response.token, refreshToken: response.refreshToken)
        return session
    }

    public func sessionLogout(session: Session, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaSessionLogout(
            body: NakamaSessionLogoutRequest(token: session.token, refreshToken: session.refreshToken)
        ), session: session, retryConfig)
    }

    public func healthcheck(retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaHealthcheck(), retryConfig)
    }

    private func session(
        from request: ApiRequest<NakamaSession>,
        _ retryConfig: RetryConfiguration?
    ) async throws -> Session {
        let response = try await send(request, retryConfig)
        return try Session(
            token: response.token,
            refreshToken: response.refreshToken,
            created: response.created
        )
    }

    // MARK: - Account and users

    public func getAccount(session: Session, retryConfig: RetryConfiguration? = nil) async throws -> NakamaAccount {
        try await send(ApiRequests.NakamaGetAccount(), session: session, retryConfig)
    }

    public func updateAccount(
        session: Session,
        username: String? = nil,
        displayName: String? = nil,
        avatarUrl: String? = nil,
        langTag: String? = nil,
        location: String? = nil,
        timezone: String? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaUpdateAccount(
            body: NakamaUpdateAccountRequest(
                username: username, displayName: displayName, avatarUrl: avatarUrl,
                langTag: langTag, location: location, timezone: timezone
            )
        ), session: session, retryConfig)
    }

    public func deleteAccount(session: Session, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaDeleteAccount(), session: session, retryConfig)
    }

    public func getUsers(
        session: Session,
        ids: [String] = [],
        usernames: [String] = [],
        facebookIds: [String] = [],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaUsers {
        try await send(ApiRequests.NakamaGetUsers(
            ids: ids, usernames: usernames, facebookIds: facebookIds
        ), session: session, retryConfig)
    }

    // MARK: - Friends

    public func addFriends(
        session: Session,
        ids: [String] = [],
        usernames: [String] = [],
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaAddFriends(ids: ids, usernames: usernames),
                           session: session, retryConfig)
    }

    public func deleteFriends(
        session: Session,
        ids: [String] = [],
        usernames: [String] = [],
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaDeleteFriends(ids: ids, usernames: usernames),
                           session: session, retryConfig)
    }

    public func blockFriends(
        session: Session,
        ids: [String] = [],
        usernames: [String] = [],
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaBlockFriends(ids: ids, usernames: usernames),
                           session: session, retryConfig)
    }

    public func listFriends(
        session: Session,
        state: Int? = nil,
        limit: Int? = nil,
        cursor: String = "",
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaFriendList {
        try await send(ApiRequests.NakamaListFriends(limit: limit, state: state, cursor: cursor),
                       session: session, retryConfig)
    }

    public func importFacebookFriends(
        session: Session,
        token: String,
        reset: Bool? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaImportFacebookFriends(
            reset: reset, body: NakamaAccountFacebook(token: token)
        ), session: session, retryConfig)
    }

    public func importSteamFriends(
        session: Session,
        token: String,
        reset: Bool? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaImportSteamFriends(
            reset: reset, body: NakamaAccountSteam(token: token)
        ), session: session, retryConfig)
    }

    // MARK: - Storage

    public func readStorageObjects(
        session: Session,
        objectIds: [NakamaReadStorageObjectId],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaStorageObjects {
        try await send(ApiRequests.NakamaReadStorageObjects(
            body: NakamaReadStorageObjectsRequest(objectIds: objectIds)
        ), session: session, retryConfig)
    }

    public func writeStorageObjects(
        session: Session,
        objects: [NakamaWriteStorageObject],
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaStorageObjectAcks {
        try await send(ApiRequests.NakamaWriteStorageObjects(
            body: NakamaWriteStorageObjectsRequest(objects: objects)
        ), session: session, retryConfig)
    }

    public func deleteStorageObjects(
        session: Session,
        objectIds: [NakamaDeleteStorageObjectId],
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaDeleteStorageObjects(
            body: NakamaDeleteStorageObjectsRequest(objectIds: objectIds)
        ), session: session, retryConfig)
    }

    public func listStorageObjects(
        session: Session,
        collection: String,
        userId: String = "",
        limit: Int? = nil,
        cursor: String = "",
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaStorageObjectList {
        try await send(ApiRequests.NakamaListStorageObjects(
            collection: collection, userId: userId, limit: limit, cursor: cursor
        ), session: session, retryConfig)
    }

    // MARK: - Link and unlink

    public func linkApple(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaLinkApple(body: NakamaAccountApple(token: token)),
                           session: session, retryConfig)
    }

    public func linkCustom(session: Session, id: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaLinkCustom(body: NakamaAccountCustom(id: id)),
                           session: session, retryConfig)
    }

    public func linkDevice(session: Session, id: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaLinkDevice(body: NakamaAccountDevice(id: id)),
                           session: session, retryConfig)
    }

    public func linkEmail(
        session: Session,
        email: String,
        password: String,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaLinkEmail(
            body: NakamaAccountEmail(email: email, password: password)
        ), session: session, retryConfig)
    }

    public func linkFacebook(
        session: Session,
        token: String,
        sync: Bool? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaLinkFacebook(
            sync: sync, body: NakamaAccountFacebook(token: token)
        ), session: session, retryConfig)
    }

    public func linkFacebookInstantGame(
        session: Session,
        signedPlayerInfo: String,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaLinkFacebookInstantGame(
            body: NakamaAccountFacebookInstantGame(signedPlayerInfo: signedPlayerInfo)
        ), session: session, retryConfig)
    }

    public func linkGameCenter(
        session: Session,
        playerId: String,
        bundleId: String,
        timestampSeconds: Int,
        salt: String,
        signature: String,
        publicKeyUrl: String,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaLinkGameCenter(
            body: NakamaAccountGameCenter(
                playerId: playerId, bundleId: bundleId, timestampSeconds: timestampSeconds,
                salt: salt, signature: signature, publicKeyUrl: publicKeyUrl
            )
        ), session: session, retryConfig)
    }

    public func linkGoogle(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaLinkGoogle(body: NakamaAccountGoogle(token: token)),
                           session: session, retryConfig)
    }

    public func linkSteam(
        session: Session,
        token: String,
        sync: Bool? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaLinkSteam(
            body: NakamaLinkSteamRequest(account: NakamaAccountSteam(token: token), sync: sync)
        ), session: session, retryConfig)
    }

    public func unlinkApple(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaUnlinkApple(body: NakamaAccountApple(token: token)),
                           session: session, retryConfig)
    }

    public func unlinkCustom(session: Session, id: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaUnlinkCustom(body: NakamaAccountCustom(id: id)),
                           session: session, retryConfig)
    }

    public func unlinkDevice(session: Session, id: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaUnlinkDevice(body: NakamaAccountDevice(id: id)),
                           session: session, retryConfig)
    }

    public func unlinkEmail(
        session: Session,
        email: String,
        password: String,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaUnlinkEmail(
            body: NakamaAccountEmail(email: email, password: password)
        ), session: session, retryConfig)
    }

    public func unlinkFacebook(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaUnlinkFacebook(body: NakamaAccountFacebook(token: token)),
                           session: session, retryConfig)
    }

    public func unlinkFacebookInstantGame(
        session: Session,
        signedPlayerInfo: String,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaUnlinkFacebookInstantGame(
            body: NakamaAccountFacebookInstantGame(signedPlayerInfo: signedPlayerInfo)
        ), session: session, retryConfig)
    }

    public func unlinkGameCenter(
        session: Session,
        playerId: String,
        bundleId: String,
        timestampSeconds: Int,
        salt: String,
        signature: String,
        publicKeyUrl: String,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaUnlinkGameCenter(
            body: NakamaAccountGameCenter(
                playerId: playerId, bundleId: bundleId, timestampSeconds: timestampSeconds,
                salt: salt, signature: signature, publicKeyUrl: publicKeyUrl
            )
        ), session: session, retryConfig)
    }

    public func unlinkGoogle(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaUnlinkGoogle(body: NakamaAccountGoogle(token: token)),
                           session: session, retryConfig)
    }

    public func unlinkSteam(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaUnlinkSteam(body: NakamaAccountSteam(token: token)),
                           session: session, retryConfig)
    }

    // MARK: - Groups

    public func createGroup(
        session: Session,
        name: String,
        description: String = "",
        langTag: String = "",
        avatarUrl: String = "",
        open: Bool = false,
        maxCount: Int = 0,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaGroup {
        try await send(ApiRequests.NakamaCreateGroup(
            body: NakamaCreateGroupRequest(
                name: name, description: description, langTag: langTag,
                avatarUrl: avatarUrl, open: open, maxCount: maxCount
            )
        ), session: session, retryConfig)
    }

    public func updateGroup(
        session: Session,
        groupId: String,
        name: String? = nil,
        description: String? = nil,
        langTag: String? = nil,
        avatarUrl: String? = nil,
        open: Bool? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaUpdateGroup(
            groupId: groupId,
            body: NakamaUpdateGroupRequest(
                groupId: groupId, name: name, description: description,
                langTag: langTag, avatarUrl: avatarUrl, open: open
            )
        ), session: session, retryConfig)
    }

    public func deleteGroup(session: Session, groupId: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaDeleteGroup(groupId: groupId), session: session, retryConfig)
    }

    public func listGroups(
        session: Session,
        name: String = "",
        cursor: String = "",
        limit: Int? = nil,
        langTag: String = "",
        members: Int? = nil,
        open: Bool? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaGroupList {
        try await send(ApiRequests.NakamaListGroups(
            name: name, cursor: cursor, limit: limit, langTag: langTag, members: members, open: open
        ), session: session, retryConfig)
    }

    public func listGroupUsers(
        session: Session,
        groupId: String,
        limit: Int? = nil,
        state: Int? = nil,
        cursor: String = "",
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaGroupUserList {
        try await send(ApiRequests.NakamaListGroupUsers(
            groupId: groupId, limit: limit, state: state, cursor: cursor
        ), session: session, retryConfig)
    }

    public func listUserGroups(
        session: Session,
        userId: String,
        limit: Int? = nil,
        state: Int? = nil,
        cursor: String = "",
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaUserGroupList {
        try await send(ApiRequests.NakamaListUserGroups(
            userId: userId, limit: limit, state: state, cursor: cursor
        ), session: session, retryConfig)
    }

    public func joinGroup(session: Session, groupId: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaJoinGroup(groupId: groupId), session: session, retryConfig)
    }

    public func leaveGroup(session: Session, groupId: String, retryConfig: RetryConfiguration? = nil) async throws {
        _ = try await send(ApiRequests.NakamaLeaveGroup(groupId: groupId), session: session, retryConfig)
    }

    public func addGroupUsers(
        session: Session,
        groupId: String,
        userIds: [String],
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaAddGroupUsers(groupId: groupId, userIds: userIds),
                           session: session, retryConfig)
    }

    public func banGroupUsers(
        session: Session,
        groupId: String,
        userIds: [String],
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaBanGroupUsers(groupId: groupId, userIds: userIds),
                           session: session, retryConfig)
    }

    public func kickGroupUsers(
        session: Session,
        groupId: String,
        userIds: [String],
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaKickGroupUsers(groupId: groupId, userIds: userIds),
                           session: session, retryConfig)
    }

    public func promoteGroupUsers(
        session: Session,
        groupId: String,
        userIds: [String],
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaPromoteGroupUsers(groupId: groupId, userIds: userIds),
                           session: session, retryConfig)
    }

    public func demoteGroupUsers(
        session: Session,
        groupId: String,
        userIds: [String],
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaDemoteGroupUsers(groupId: groupId, userIds: userIds),
                           session: session, retryConfig)
    }

    // MARK: - Leaderboards

    public func writeLeaderboardRecord(
        session: Session,
        leaderboardId: String,
        score: Int,
        subscore: Int = 0,
        metadata: String = "",
        operator: NakamaOperator = .noOverride,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaLeaderboardRecord {
        try await send(ApiRequests.NakamaWriteLeaderboardRecord(
            leaderboardId: leaderboardId,
            body: NakamaWriteLeaderboardRecordRequestLeaderboardRecordWrite(
                score: score, subscore: subscore, metadata: metadata, operator_: `operator`
            )
        ), session: session, retryConfig)
    }

    public func deleteLeaderboardRecord(
        session: Session,
        leaderboardId: String,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaDeleteLeaderboardRecord(leaderboardId: leaderboardId),
                           session: session, retryConfig)
    }

    public func listLeaderboardRecords(
        session: Session,
        leaderboardId: String,
        ownerIds: [String] = [],
        limit: Int? = nil,
        cursor: String = "",
        expiry: Int? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaLeaderboardRecordList {
        try await send(ApiRequests.NakamaListLeaderboardRecords(
            leaderboardId: leaderboardId, ownerIds: ownerIds, limit: limit, cursor: cursor, expiry: expiry
        ), session: session, retryConfig)
    }

    public func listLeaderboardRecordsAroundOwner(
        session: Session,
        leaderboardId: String,
        ownerId: String,
        limit: Int? = nil,
        expiry: Int? = nil,
        cursor: String = "",
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaLeaderboardRecordList {
        try await send(ApiRequests.NakamaListLeaderboardRecordsAroundOwner(
            leaderboardId: leaderboardId, ownerId: ownerId, limit: limit, expiry: expiry, cursor: cursor
        ), session: session, retryConfig)
    }

    // MARK: - Tournaments

    public func listTournaments(
        session: Session,
        categoryStart: Int? = nil,
        categoryEnd: Int? = nil,
        startTime: Int? = nil,
        endTime: Int? = nil,
        limit: Int? = nil,
        cursor: String = "",
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaTournamentList {
        try await send(ApiRequests.NakamaListTournaments(
            categoryStart: categoryStart, categoryEnd: categoryEnd,
            startTime: startTime, endTime: endTime, limit: limit, cursor: cursor
        ), session: session, retryConfig)
    }

    public func joinTournament(
        session: Session,
        tournamentId: String,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaJoinTournament(tournamentId: tournamentId),
                           session: session, retryConfig)
    }

    public func writeTournamentRecord(
        session: Session,
        tournamentId: String,
        score: Int,
        subscore: Int = 0,
        metadata: String = "",
        operator: NakamaOperator = .noOverride,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaLeaderboardRecord {
        try await send(ApiRequests.NakamaWriteTournamentRecord(
            tournamentId: tournamentId,
            body: NakamaWriteTournamentRecordRequestTournamentRecordWrite(
                score: score, subscore: subscore, metadata: metadata, operator_: `operator`
            )
        ), session: session, retryConfig)
    }

    public func deleteTournamentRecord(
        session: Session,
        tournamentId: String,
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaDeleteTournamentRecord(tournamentId: tournamentId),
                           session: session, retryConfig)
    }

    public func listTournamentRecords(
        session: Session,
        tournamentId: String,
        ownerIds: [String] = [],
        limit: Int? = nil,
        cursor: String = "",
        expiry: Int? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaTournamentRecordList {
        try await send(ApiRequests.NakamaListTournamentRecords(
            tournamentId: tournamentId, ownerIds: ownerIds, limit: limit, cursor: cursor, expiry: expiry
        ), session: session, retryConfig)
    }

    public func listTournamentRecordsAroundOwner(
        session: Session,
        tournamentId: String,
        ownerId: String,
        limit: Int? = nil,
        expiry: Int? = nil,
        cursor: String = "",
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaTournamentRecordList {
        try await send(ApiRequests.NakamaListTournamentRecordsAroundOwner(
            tournamentId: tournamentId, ownerId: ownerId, limit: limit, expiry: expiry, cursor: cursor
        ), session: session, retryConfig)
    }

    // MARK: - Chat, notifications, matches

    public func listChannelMessages(
        session: Session,
        channelId: String,
        limit: Int? = nil,
        forward: Bool? = nil,
        cursor: String = "",
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaChannelMessageList {
        try await send(ApiRequests.NakamaListChannelMessages(
            channelId: channelId, limit: limit, forward: forward, cursor: cursor
        ), session: session, retryConfig)
    }

    public func listNotifications(
        session: Session,
        limit: Int? = nil,
        cacheableCursor: String = "",
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaNotificationList {
        try await send(ApiRequests.NakamaListNotifications(
            limit: limit, cacheableCursor: cacheableCursor
        ), session: session, retryConfig)
    }

    public func deleteNotifications(
        session: Session,
        ids: [String],
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaDeleteNotifications(ids: ids), session: session, retryConfig)
    }

    public func listMatches(
        session: Session,
        limit: Int? = nil,
        authoritative: Bool? = nil,
        label: String? = nil,
        minSize: Int? = nil,
        maxSize: Int? = nil,
        query: String? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaMatchList {
        try await send(ApiRequests.NakamaListMatches(
            limit: limit, authoritative: authoritative, label: label,
            minSize: minSize, maxSize: maxSize, query: query
        ), session: session, retryConfig)
    }

    // MARK: - Purchases and subscriptions

    public func validatePurchaseApple(
        session: Session,
        receipt: String,
        persist: Bool? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaValidatePurchaseResponse {
        try await send(ApiRequests.NakamaValidatePurchaseApple(
            body: NakamaValidatePurchaseAppleRequest(receipt: receipt, persist: persist)
        ), session: session, retryConfig)
    }

    public func validatePurchaseGoogle(
        session: Session,
        purchase: String,
        persist: Bool? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaValidatePurchaseResponse {
        try await send(ApiRequests.NakamaValidatePurchaseGoogle(
            body: NakamaValidatePurchaseGoogleRequest(purchase: purchase, persist: persist)
        ), session: session, retryConfig)
    }

    public func validatePurchaseHuawei(
        session: Session,
        purchase: String,
        signature: String,
        persist: Bool? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaValidatePurchaseResponse {
        try await send(ApiRequests.NakamaValidatePurchaseHuawei(
            body: NakamaValidatePurchaseHuaweiRequest(
                purchase: purchase, signature: signature, persist: persist
            )
        ), session: session, retryConfig)
    }

    public func validateSubscriptionApple(
        session: Session,
        receipt: String,
        persist: Bool? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaValidateSubscriptionResponse {
        try await send(ApiRequests.NakamaValidateSubscriptionApple(
            body: NakamaValidateSubscriptionAppleRequest(receipt: receipt, persist: persist)
        ), session: session, retryConfig)
    }

    public func validateSubscriptionGoogle(
        session: Session,
        receipt: String,
        persist: Bool? = nil,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaValidateSubscriptionResponse {
        try await send(ApiRequests.NakamaValidateSubscriptionGoogle(
            body: NakamaValidateSubscriptionGoogleRequest(receipt: receipt, persist: persist)
        ), session: session, retryConfig)
    }

    public func getSubscription(
        session: Session,
        productId: String,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaValidatedSubscription {
        try await send(ApiRequests.NakamaGetSubscription(productId: productId),
                       session: session, retryConfig)
    }

    public func listSubscriptions(
        session: Session,
        limit: Int? = nil,
        cursor: String = "",
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaSubscriptionList {
        try await send(ApiRequests.NakamaListSubscriptions(
            body: NakamaListSubscriptionsRequest(limit: limit, cursor: cursor)
        ), session: session, retryConfig)
    }

    // MARK: - Rpc and events

    public func rpc(
        session: Session,
        id: String,
        payload: String = "",
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaRpc {
        try await send(ApiRequests.NakamaRpcFunc(id: id, body: payload),
                       session: session, retryConfig)
    }

    /// Call an rpc with the server's HTTP key instead of a session. Server-to-server use.
    public func rpc(
        id: String,
        payload: String = "",
        httpKey: String,
        retryConfig: RetryConfiguration? = nil
    ) async throws -> NakamaRpc {
        try await send(ApiRequests.NakamaRpcFunc(id: id, httpKey: httpKey, body: payload), retryConfig)
    }

    /// Submit an event to the server's registered runtime custom events handler.
    public func event(
        session: Session,
        name: String,
        timestamp: Date = Date(),
        external: Bool = false,
        properties: [String: String] = [:],
        retryConfig: RetryConfiguration? = nil
    ) async throws {
        _ = try await send(ApiRequests.NakamaEvent(
            body: NakamaEvent(
                name: name, timestamp: timestamp, external: external, properties: properties
            )
        ), session: session, retryConfig)
    }
}

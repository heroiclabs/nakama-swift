/*
 * Copyright 2021 The Nakama Authors
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
import GRPC
import NIO
import Logging
import SwiftProtobuf

public final class GrpcClient : Client {
    public var eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    public var retriesLimit = 5
    public var globalRetryConfiguration: RetryConfiguration
    public var autoRefreshSession: Bool
    
    public let host: String
    public let port: Int
    public let ssl: Bool
    public let transientErrorAdapter: TransientErrorAdapter?
    public let defaultExpiredTimeSpan: TimeInterval = 5 * 60
    
    private let retryInvoker: RetryInvoker
    
    let serverKey: String
    let grpcConnection: ClientConnection
    let nakamaGrpcClient: Nakama_Api_NakamaClientProtocol
    var logger : Logger?
    
    /**
     A client to interact with Nakama server.
     - Parameter serverKey: The key used to authenticate with the server without a session. Defaults to "defaultkey".
     - Parameter host: The host address of the server. Defaults to "127.0.0.1".
     - Parameter port: The port number of the server. Defaults to 7349.
     - Parameter ssl Set connection strings to use the secure mode with the server. Defaults to false. The server must be configured to make use of this option. With HTTP, GRPC, and WebSockets the server must
     be configured with an SSL certificate or use a load balancer which performs SSL termination.
     - Parameter deadlineAfter: Timeout for the gRPC messages in seconds.
     - Parameter keepAliveTimeout: Sets the time waiting for read activity after sending a keepalive ping. If the time expires
     without any read activity on the connection, the connection is considered dead. An unreasonably
     small value might be increased. Defaults to 20 seconds.
     - Parameter trace: Trace all actions performed by the client. Defaults to false.
     */
    public init(serverKey: String, host: String = "127.0.0.1", port: Int = 7349, ssl: Bool = false, deadlineAfter: TimeInterval = 20.0, keepAliveTimeout: TimeAmount = .seconds(20), trace: Bool = false, transientErrorAdapter: TransientErrorAdapter? = nil, autoRefreshSession: Bool = true) {
        let base64Auth = "\(serverKey):".data(using: String.Encoding.utf8)!.base64EncodedString()
        let basicAuth = "Basic \(base64Auth)"
        var callOptions = CallOptions(cacheable: false)
        callOptions.customMetadata.add(name: "authorization", value: basicAuth)
        
        var configuration = ClientConnection.Configuration.default(target: .hostAndPort(host, port), eventLoopGroup: self.eventLoopGroup)
        configuration.connectionBackoff = ConnectionBackoff(minimumConnectionTimeout: deadlineAfter, retries: .upTo(retriesLimit))
        configuration.connectionKeepalive = ClientConnectionKeepalive(timeout: keepAliveTimeout, permitWithoutCalls: true)
        configuration.callStartBehavior = .fastFailure
        
        if ssl {
            configuration.tlsConfiguration = .init(GRPCTLSConfiguration.makeClientDefault(compatibleWith: eventLoopGroup))
        }
        
        if trace {
            logger = Logger(label: "com.heroiclabs.nakama-swift")
            configuration.backgroundActivityLogger = logger!
            callOptions.logger = logger!
        }
        
        logger?.debug("Dialing grpc server \(host):\(port) with basic auth \(basicAuth)")
        print("Dialing grpc server \(host):\(port) with basic auth \(basicAuth)")
        
        self.grpcConnection = ClientConnection(configuration: configuration)
        self.serverKey = serverKey
        self.host = host
        self.port = port
        self.ssl = ssl
        self.transientErrorAdapter = transientErrorAdapter ?? TransientErrorAdapter()
        self.autoRefreshSession = autoRefreshSession
        
        retryInvoker = RetryInvoker(transientErrorAdapter: self.transientErrorAdapter!)
        globalRetryConfiguration = RetryConfiguration(baseDelayMs: 500, maxRetries: 4)
        
        self.nakamaGrpcClient = Nakama_Api_NakamaNIOClient(channel: grpcConnection, defaultCallOptions: callOptions)
    }
    
    public func disconnect() async throws -> Void {
        return try await self.grpcConnection.close().get()
    }
    
    public func createSocket(host: String? = nil, port: Int? = nil, ssl: Bool? = nil, socketAdapter: SocketAdapter? = nil) -> SocketProtocol {
        return Socket(host: host ?? self.host, port: port ?? 7350, ssl: ssl ?? self.ssl, eventLoopGroup: self.eventLoopGroup, socketAdapter: socketAdapter, logger: self.logger)
    }
    
    public func addFriends(session: Session, ids: [String], usernames: [String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Void {
        var req = Nakama_Api_AddFriendsRequest()
        req.ids = ids
        if let usernames {
            req.usernames = usernames
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.addFriends(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func authenticateCustom(id: String, create: Bool? = true, username: String? = nil, vars: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Nakama_Api_AuthenticateCustomRequest()
        req.account = Nakama_Api_AccountCustom()
        req.account.id = id
        req.create = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.create.value = create ?? true
        if let username {
            req.username = username
        }
        if let vars {
            req.account.vars = vars
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.authenticateCustom(req).response.get()
        }, history: RetryHistory(token: id, configuration: retryConfig ?? globalRetryConfiguration)).toSession()
    }
    
    public func authenticateDevice(id: String, create: Bool? = true, username: String? = nil, vars: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Nakama_Api_AuthenticateDeviceRequest()
        req.account = Nakama_Api_AccountDevice()
        req.account.id = id
        req.create = (create ?? true).pbBoolValue
        if let username {
            req.username = username
        }
        if let vars {
            req.account.vars = vars
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.authenticateDevice(req).response.get().toSession()
        }, history: RetryHistory(token: id, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func authenticateEmail(email: String, password: String, create: Bool? = true, username: String? = nil, vars: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Nakama_Api_AuthenticateEmailRequest()
        req.account = Nakama_Api_AccountEmail()
        req.account.email = email
        req.account.password = password
        req.create = (create ?? true).pbBoolValue
        if let username {
            req.username = username
        }
        if let vars {
            req.account.vars = vars
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.authenticateEmail(req).response.get().toSession()
        }, history: RetryHistory(token: email, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func authenticateFacebook(accessToken: String, create: Bool? = true, username: String? = nil, importFriends: Bool? = true, vars: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Nakama_Api_AuthenticateFacebookRequest()
        req.account = Nakama_Api_AccountFacebook()
        req.account.token = accessToken
        req.create = (create ?? true).pbBoolValue
        if let username {
            req.username = username
        }
        if let vars {
            req.account.vars = vars
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.authenticateFacebook(req).response.get().toSession()
        }, history: RetryHistory(token: accessToken, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func authenticateGoogle(accessToken: String, create: Bool? = true, username: String? = nil, vars: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Nakama_Api_AuthenticateGoogleRequest()
        req.account = Nakama_Api_AccountGoogle()
        req.account.token = accessToken
        req.create = (create ?? true).pbBoolValue
        if let username {
            req.username = username
        }
        if let vars {
            req.account.vars = vars
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.authenticateGoogle(req).response.get().toSession()
        }, history: RetryHistory(token: accessToken, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func authenticateSteam(token: String, create: Bool? = true, username: String? = nil, vars: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Nakama_Api_AuthenticateSteamRequest()
        req.account = Nakama_Api_AccountSteam()
        req.account.token = token
        req.create = (create ?? true).pbBoolValue
        if let username {
            req.username = username
        }
        if let vars {
            req.account.vars = vars
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.authenticateSteam(req).response.get().toSession()
        }, history: RetryHistory(token: token, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func authenticateApple(token: String, create: Bool? = true, username: String? = nil, vars: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Nakama_Api_AuthenticateAppleRequest()
        req.account = Nakama_Api_AccountApple()
        req.account.token = token
        req.create = (create ?? true).pbBoolValue
        if let username {
            req.username = username
        }
        if let vars {
            req.account.vars = vars
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.authenticateApple(req).response.get().toSession()
        }, history: RetryHistory(token: token, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool? = true, username: String? = nil, vars: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Nakama_Api_AuthenticateFacebookInstantGameRequest()
        req.account = Nakama_Api_AccountFacebookInstantGame()
        req.account.signedPlayerInfo = signedPlayerInfo
        req.create = (create ?? true).pbBoolValue
        if let username {
            req.username = username
        }
        if let vars {
            req.account.vars = vars
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.authenticateFacebookInstantGame(req).response.get().toSession()
        }, history: RetryHistory(token: signedPlayerInfo, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool? = true, username: String? = nil, vars: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Nakama_Api_AuthenticateGameCenterRequest()
        req.account = Nakama_Api_AccountGameCenter()
        req.account.playerID = playerId
        req.account.bundleID = bundleId
        req.account.timestampSeconds = timestampSeconds
        req.account.salt = salt
        req.account.signature = signature
        req.account.publicKeyURL = publicKeyUrl
        req.create = (create ?? true).pbBoolValue
        if let username {
            req.username = username
        }
        if let vars {
            req.account.vars = vars
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.authenticateGameCenter(req).response.get().toSession()
        }, history: RetryHistory(token: bundleId, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getAccount(session: Session, retryConfig: RetryConfiguration? = nil) async throws -> ApiAccount {
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.getAccount(Google_Protobuf_Empty(), callOptions: session.callOptions).response.get().toApiAccount()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func refreshSession(session: Session, vars: [String : String]? = nil, retryConfig: RetryConfiguration? = nil) async throws -> Session {
        var req = Nakama_Api_SessionRefreshRequest()
        req.token = session.refreshToken
        if let vars {
            req.vars = vars
        }
        
        let refreshed = try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.sessionRefresh(req, callOptions: nil).response.get().toSession()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
        
        if let updatedSession = session as? DefaultSession {
            updatedSession.update(authToken: refreshed.token, refreshToken: refreshed.refreshToken)
            return updatedSession
        }
        
        return DefaultSession(token: refreshed.token, refreshToken: refreshed.refreshToken, created: refreshed.created)
    }
    
    public func sessionLogout(session: Session, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_SessionLogoutRequest()
        req.token = session.token
        req.refreshToken = session.refreshToken
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.sessionLogout(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func writeStorageObjects(session: Session, objects: [WriteStorageObject], retryConfig: RetryConfiguration? = nil) async throws -> StorageObjectAcks {
        var writes = [Nakama_Api_WriteStorageObject]()
        
        for item in objects {
            var object = Nakama_Api_WriteStorageObject()
            object.collection = item.collection
            object.key = item.key
            object.value = item.value
            object.version = item.version
            object.permissionRead = item.readPermission.rawValue.pbInt32Value
            object.permissionWrite = item.writePermission.rawValue.pbInt32Value
            writes.append(object)
        }
        
        var req = Nakama_Api_WriteStorageObjectsRequest()
        req.objects = writes
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.writeStorageObjects(req, callOptions: session.callOptions).response.get().toStorageObjectAcks()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func readStorageObjects(session: Session, ids: [StorageObjectId], retryConfig: RetryConfiguration? = nil) async throws -> [StorageObject] {
        var objectIds = [Nakama_Api_ReadStorageObjectId]()
        
        for id in ids {
            var readObject = Nakama_Api_ReadStorageObjectId()
            readObject.collection = id.collection
            readObject.key = id.key
            readObject.userID = id.userId
            objectIds.append(readObject)
        }
        
        var req = Nakama_Api_ReadStorageObjectsRequest()
        req.objectIds = objectIds
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.readStorageObjects(req, callOptions: session.callOptions).response.get().objects.map { $0.toStorageObject()}
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func deleteStorageObjects(session: Session, ids: [StorageObjectId], retryConfig: RetryConfiguration? = nil) async throws -> Void {
        var objectIds = [Nakama_Api_DeleteStorageObjectId]()
        
        for id in ids {
            var deleteObject = Nakama_Api_DeleteStorageObjectId()
            deleteObject.collection = id.collection
            deleteObject.key = id.key
            deleteObject.version = id.version
            objectIds.append(deleteObject)
        }
        
        var req = Nakama_Api_DeleteStorageObjectsRequest()
        req.objectIds = objectIds
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.deleteStorageObjects(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listStorageObjects(session: Session, collection: String, limit: Int = 1, cursor: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> StorageObjectList {
        var req = Nakama_Api_ListStorageObjectsRequest()
        req.collection = collection
        req.userID = session.userId
        req.limit = limit.pbInt32Value
        req.cursor = cursor ?? ""
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.listStorageObjects(req, callOptions: session.callOptions).response.get().toStorageObjectList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func rpc(session: Session, id: String, payload: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> ApiRpc? {
        var req = Nakama_Api_Rpc()
        req.id = id
        if let payload {
            req.payload = payload
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.rpcFunc(req, callOptions: session.callOptions).response.get().toApiRpc()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func writeLeaderboardRecord(session: Session, leaderboardId: String, score: Int, subScore: Int? = 0, metadata: String? = nil, leaderboardOperator: LeaderboardOperator? = .noOverride, retryConfig: RetryConfiguration? = nil) async throws -> LeaderboardRecord {
        var req = Nakama_Api_WriteLeaderboardRecordRequest()
        
        var record = Nakama_Api_WriteLeaderboardRecordRequest.LeaderboardRecordWrite()
        if let leaderboardOperator {
            record.operator = Nakama_Api_Operator(rawValue: leaderboardOperator.rawValue) ?? .noOverride
        }
        if let metadata {
            record.metadata = metadata
        }
        record.score = Int64(score)
        if let subScore {
            record.subscore = Int64(subScore)
        }
        req.leaderboardID = leaderboardId
        req.record = record
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.writeLeaderboardRecord(req, callOptions: session.callOptions).response.get().toLeaderboardRecord()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listLeaderboardRecords(session: Session, leaderboardId: String, ownerIds: [String]? = nil, expiry: Int? = nil, limit: Int = 1, cursor: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> LeaderboardRecordList {
        var req = Nakama_Api_ListLeaderboardRecordsRequest()
        req.leaderboardID = leaderboardId
        if let ownerIds {
            req.ownerIds = ownerIds
        }
        if let expiry {
            req.expiry = (expiry).pbInt64Value
        }
        req.limit = limit.pbInt32Value
        req.cursor = cursor ?? ""
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.listLeaderboardRecords(req, callOptions: session.callOptions).response.get().toLeaderboardRecordList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listLeaderboardRecordsAroundOwner(session: Session, leaderboardId: String, ownerId: String, expiry: Int? = nil, limit: Int = 1, cursor: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> LeaderboardRecordList {
        var req = Nakama_Api_ListLeaderboardRecordsAroundOwnerRequest()
        req.leaderboardID = leaderboardId
        req.ownerID = ownerId
        if let expiry {
            req.expiry = expiry.pbInt64Value
        }
        req.limit = limit.pbUint32Value
        req.cursor = cursor ?? ""
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.listLeaderboardRecordsAroundOwner(req, callOptions: session.callOptions).response.get().toLeaderboardRecordList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func deleteLeaderboardRecord(session: Session, leaderboardId: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_DeleteLeaderboardRecordRequest()
        req.leaderboardID = leaderboardId
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.deleteLeaderboardRecord(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func joinTournament(session: Session, tournamentId: String, retryConfig: RetryConfiguration? = nil) async throws -> Void {
        var req = Nakama_Api_JoinTournamentRequest()
        req.tournamentID = tournamentId
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.joinTournament(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listTournaments(session: Session, categoryStart: Int, categoryEnd: Int, startTime: Int? = nil, endTime: Int? = nil, limit: Int = 1, cursor: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> TournamentList {
        var req = Nakama_Api_ListTournamentsRequest()
        req.categoryStart = categoryStart.pbUint32Value
        req.categoryEnd = categoryEnd.pbUint32Value
        if let startTime {
            req.startTime = startTime.pbUint32Value
        }
        if let endTime {
            req.endTime = endTime.pbUint32Value
        }
        req.limit = limit.pbInt32Value
        req.cursor = cursor ?? ""
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.listTournaments(req, callOptions: session.callOptions).response.get().toTournamentList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func writeTournamentRecord(session: Session, tournamentId: String, score: Int, subScore: Int? = 0, metadata: String? = nil, apiOperator: TournamentOperator? = .noOverride, retryConfig: RetryConfiguration? = nil) async throws -> LeaderboardRecord {
        var req = Nakama_Api_WriteTournamentRecordRequest()
        req.tournamentID = tournamentId
        
        var record = Nakama_Api_WriteTournamentRecordRequest.TournamentRecordWrite()
        if let apiOperator {
            record.operator = Nakama_Api_Operator(rawValue: apiOperator.rawValue) ?? .noOverride
        }
        record.score = Int64(score)
        if let subScore {
            record.subscore = Int64(subScore)
        }
        if let metadata {
            record.metadata = metadata
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.writeTournamentRecord(req, callOptions: session.callOptions).response.get().toLeaderboardRecord()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listTournamentRecords(session: Session, tournamentId: String, ownerIds: [String]? = nil, expiry: Int? = nil, limit: Int = 1, cursor: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> TournamentRecordList {
        var req =  Nakama_Api_ListTournamentRecordsRequest()
        req.tournamentID = tournamentId
        if let ownerIds {
            req.ownerIds = ownerIds
        }
        if let expiry {
            req.expiry = expiry.pbInt64Value
        }
        req.limit = limit.pbInt32Value
        req.cursor = cursor ?? ""
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.listTournamentRecords(req, callOptions: session.callOptions).response.get().toTournamentRecordList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listTournamentRecordsAroundOwner(session: Session, tournamentId: String, ownerId: String, expiry: Int? = nil, limit: Int = 1, cursor: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> TournamentRecordList {
        var req = Nakama_Api_ListTournamentRecordsAroundOwnerRequest()
        req.tournamentID = tournamentId
        req.ownerID = ownerId
        if let expiry {
            req.expiry = expiry.pbInt64Value
        }
        req.limit = limit.pbUint32Value
        req.cursor = cursor ?? ""
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.listTournamentRecordsAroundOwner(req, callOptions: session.callOptions).response.get().toTournamentRecordList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func createGroup(session: Session, name: String, description: String? = nil, avatarUrl: String? = nil, langTag: String? = nil, open: Bool? = true, maxCount: Int? = 100, retryConfig: RetryConfiguration? = nil) async throws -> Group {
        var req = Nakama_Api_CreateGroupRequest()
        req.name = name
        if let description {
            req.description_p = description
        }
        if let avatarUrl {
            req.avatarURL = avatarUrl
        }
        if let langTag {
            req.langTag = langTag
        }
        req.open = open ?? true
        req.maxCount = Int32(maxCount ?? 100)
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.createGroup(req, callOptions: session.callOptions).response.get().toGroup()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func joinGroup(session: Session, groupId: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_JoinGroupRequest()
        req.groupID = groupId
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.joinGroup(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func leaveGroup(session: Session, groupId: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_LeaveGroupRequest()
        req.groupID = groupId
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.leaveGroup(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func deleteGroup(session: Session, groupId: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_DeleteGroupRequest()
        req.groupID = groupId
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.deleteGroup(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listGroups(session: Session, name: String? = nil, limit: Int = 1, cursor: String? = nil, langTag: String? = nil, members: Int? = nil, open: Bool? = nil, retryConfig: RetryConfiguration? = nil) async throws -> GroupList {
        var req = Nakama_Api_ListGroupsRequest()
        if let name {
            req.name = name
        }
        req.limit = limit.pbInt32Value
        if let cursor {
            req.cursor = cursor
        }
        if let langTag {
            req.langTag = langTag
        }
        if let members {
            req.members = members.pbInt32Value
        }
        if let open {
            req.open = open.pbBoolValue
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.listGroups(req, callOptions: session.callOptions).response.get().toGroupList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func updateGroup(session: Session, groupId: String, name: String? = nil, open: Bool, description: String? = nil, avatarUrl: String? = nil, langTag: String? = nil, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_UpdateGroupRequest()
        req.groupID = groupId
        req.open = open.pbBoolValue
        if let name {
            req.name = name.pbStringValue
        }
        if let description {
            req.description_p = description.pbStringValue
        }
        if let avatarUrl {
            req.avatarURL = avatarUrl.pbStringValue
        }
        if let langTag {
            req.langTag = langTag.pbStringValue
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.updateGroup(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func addGroupUsers(session: Session, groupId: String, ids: [String], retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AddGroupUsersRequest()
        req.groupID = groupId
        req.userIds = ids
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.addGroupUsers(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func kickGroupUsers(session: Session, groupId: String, ids: [String], retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_KickGroupUsersRequest()
        req.groupID = groupId
        req.userIds = ids
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.kickGroupUsers(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listGroupUsers(session: Session, groupId: String, state: Int? = nil, limit: Int, cursor: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> GroupUserList {
        var req = Nakama_Api_ListGroupUsersRequest()
        req.groupID = groupId
        if let state {
            req.state = state.pbInt32Value
        }
        req.limit = limit.pbInt32Value
        if let cursor {
            req.cursor = cursor
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.listGroupUsers(req, callOptions: session.callOptions).response.get().toGroupUserList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listUserGroups(session: Session, userId: String? = nil, state: Int? = nil, limit: Int = 1, cursor: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> ListUserGroup {
        var req = Nakama_Api_ListUserGroupsRequest()
        req.userID = userId ?? session.userId
        if let state {
            req.state = state.pbInt32Value
        }
        req.limit = limit.pbInt32Value
        if let cursor {
            req.cursor = cursor
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.listUserGroups(req, callOptions: session.callOptions).response.get().toUserGroupList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func promoteGroupUsers(session: Session, groupId: String, ids: [String], retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_PromoteGroupUsersRequest()
        req.groupID = groupId
        req.userIds = ids
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.promoteGroupUsers(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func demoteGroupUsers(session: Session, groupId: String, ids: [String], retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_DemoteGroupUsersRequest()
        req.groupID = groupId
        req.userIds = ids
        _ = try await nakamaGrpcClient.demoteGroupUsers(req, callOptions: session.callOptions).response.get()
    }
    
    public func banGroupUsers(session: Session, groupId: String, ids: [String], retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_BanGroupUsersRequest()
        req.groupID = groupId
        req.userIds = ids
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.banGroupUsers(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func validatePurchaseApple(session: Session, receipt: String, persist: Bool? = true, retryConfig: RetryConfiguration? = nil) async throws -> ValidatePurchaseResponse {
        var req = Nakama_Api_ValidatePurchaseAppleRequest()
        req.receipt = receipt
        req.persist = (persist ?? true).pbBoolValue
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.validatePurchaseApple(req, callOptions: session.callOptions).response.get().toValidatePurchaseResponse()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func validatePurchaseGoogle(session: Session, receipt: String, persist: Bool? = true, retryConfig: RetryConfiguration? = nil) async throws -> ValidatePurchaseResponse {
        var req = Nakama_Api_ValidatePurchaseGoogleRequest()
        req.purchase = receipt
        req.persist = (persist ?? true).pbBoolValue
        
        return try await nakamaGrpcClient.validatePurchaseGoogle(req, callOptions: session.callOptions).response.get().toValidatePurchaseResponse()
    }
    
    public func validatePurchaseHuawei(session: Session, receipt: String, persist: Bool? = true, retryConfig: RetryConfiguration? = nil) async throws -> ValidatePurchaseResponse {
        var req = Nakama_Api_ValidatePurchaseHuaweiRequest()
        req.purchase = receipt
        req.persist = (persist ?? true).pbBoolValue
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.validatePurchaseHuawei(req, callOptions: session.callOptions).response.get().toValidatePurchaseResponse()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func getSubscription(session: Session, productId: String, retryConfig: RetryConfiguration? = nil) async throws -> ValidatedSubscription {
        var req = Nakama_Api_GetSubscriptionRequest()
        req.productID = productId
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.getSubscription(req, callOptions: session.callOptions).response.get().toValidatedSubscription()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func validateSubscriptionApple(session: Session, receipt: String, persist: Bool? = true, retryConfig: RetryConfiguration? = nil) async throws -> ValidateSubscriptionResponse {
        var req = Nakama_Api_ValidateSubscriptionAppleRequest()
        req.receipt = receipt
        req.persist = (persist ?? true).pbBoolValue
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.validateSubscriptionApple(req, callOptions: session.callOptions).response.get().toValidatedSubscriptionResponse()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func validateSubscriptionGoogle(session: Session, receipt: String, persist: Bool? = true, retryConfig: RetryConfiguration? = nil) async throws -> ValidateSubscriptionResponse {
        var req = Nakama_Api_ValidateSubscriptionGoogleRequest()
        req.receipt = receipt
        req.persist = (persist ?? true).pbBoolValue
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.validateSubscriptionGoogle(req, callOptions: session.callOptions).response.get().toValidatedSubscriptionResponse()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listSubscriptions(session: Session, limit: Int, cursor: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> SubscriptionList {
        var req = Nakama_Api_ListSubscriptionsRequest()
        req.limit = limit.pbInt32Value
        if let cursor {
            req.cursor = cursor
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.listSubscriptions(req, callOptions: session.callOptions).response.get().toSubscriptionList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func listNotifications(session: Session, limit: Int = 1, cacheableCursor: String? = nil, retryConfig: RetryConfiguration? = nil) async throws -> NotificationList {
        var req = Nakama_Api_ListNotificationsRequest()
        if let cacheableCursor {
            req.cacheableCursor = cacheableCursor
        }
        req.limit = limit.pbInt32Value
        
        return try await retryInvoker.invokeWithRetry(request: {
            return try await self.nakamaGrpcClient.listNotifications(req, callOptions: session.callOptions).response.get().toNotificationList()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func deleteNotifications(session: Session, ids: [String], retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_DeleteNotificationsRequest()
        req.ids = ids
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.deleteNotifications(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func linkApple(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountApple()
        req.token = token
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.linkApple(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func linkEmail(session: Session, email: String, password: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountEmail()
        req.email = email
        req.password = password
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.linkEmail(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func linkSteam(session: Session, token: String, import: Bool, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_LinkSteamRequest()
        req.account.token = token
        req.sync = `import`.pbBoolValue
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.linkSteam(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func linkDevice(session: Session, id: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountDevice()
        req.id = id
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.linkDevice(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func linkCustom(session: Session, id: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountCustom()
        req.id = id
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.linkCustom(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func linkGoogle(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountGoogle()
        req.token = token
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.linkGoogle(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func linkFacebook(session: Session, token: String, import: Bool? = true, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_LinkFacebookRequest()
        req.account.token = token
        req.sync = (`import` ?? true).pbBoolValue
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.linkFacebook(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func linkGameCenter(session: Session, bundleId: String, playerId: String, publicKeyUrl: String, salt: String, signature: String, timestamp: Int, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountGameCenter()
        req.bundleID = bundleId
        req.playerID = playerId
        req.publicKeyURL = publicKeyUrl
        req.salt = salt
        req.signature = signature
        req.timestampSeconds = Int64(timestamp)
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.linkGameCenter(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func unlinkApple(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountApple()
        req.token = token
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.unlinkApple(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func unlinkEmail(session: Session, email: String, password: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountEmail()
        req.email = email
        req.password = password
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.unlinkEmail(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func unlinkSteam(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountSteam()
        req.token = token
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.unlinkSteam(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func unlinkDevice(session: Session, id: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountDevice()
        req.id = id
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.unlinkDevice(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func unlinkCustom(session: Session, id: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountCustom()
        req.id = id
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.unlinkCustom(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func unlinkGoogle(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountGoogle()
        req.token = token
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.unlinkGoogle(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func unlinkFacebook(session: Session, token: String, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountFacebook()
        req.token = token
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.unlinkFacebook(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func unlinkGameCenter(session: Session, bundleId: String, playerId: String, publicKeyUrl: String, salt: String, signature: String, timestamp: Int, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_AccountGameCenter()
        req.bundleID = bundleId
        req.playerID = playerId
        req.publicKeyURL = publicKeyUrl
        req.salt = salt
        req.signature = signature
        req.timestampSeconds = Int64(timestamp)
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.unlinkGameCenter(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func importFacebookFriends(session: Session, token: String, reset: Bool? = nil, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_ImportFacebookFriendsRequest()
        req.account.token = token
        if let reset {
            req.reset = reset.pbBoolValue
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.importFacebookFriends(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
    
    public func importSteamFriends(session: Session, token: String, reset: Bool? = nil, retryConfig: RetryConfiguration? = nil) async throws {
        var req = Nakama_Api_ImportSteamFriendsRequest()
        req.account.token = token
        if let reset {
            req.reset = reset.pbBoolValue
        }
        
        return try await retryInvoker.invokeWithRetry(request: {
            _ = try await self.nakamaGrpcClient.importSteamFriends(req, callOptions: session.callOptions).response.get()
        }, history: RetryHistory(session: session, configuration: retryConfig ?? globalRetryConfiguration))
    }
}

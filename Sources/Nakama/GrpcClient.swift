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

public class GrpcClient : Client {
    
    public var eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    public var retriesLimit = 5
    
    public let host: String
    public let port: Int
    public let ssl: Bool
    let serverKey: String
    let grpcConnection: ClientConnection
    let nakamaGrpcClient: Nakama_Api_NakamaClientProtocol
    var logger : Logger?
    
    func sessionCallOption(session: Session) -> CallOptions {
        var callOptions = CallOptions(cacheable: false)
        callOptions.customMetadata.add(name: "authorization", value: "Bearer " + session.token)
        return callOptions
    }
    
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
    public init(serverKey: String, host: String = "127.0.0.1", port: Int = 7349, ssl: Bool = false, deadlineAfter: TimeInterval = 20.0, keepAliveTimeout: TimeAmount = .seconds(20), trace: Bool = false) {
        
        let base64Auth = "\(serverKey):".data(using: String.Encoding.utf8)!.base64EncodedString()
        let basicAuth = "Basic \(base64Auth)"
        var callOptions = CallOptions(cacheable: false)
        callOptions.customMetadata.add(name: "authorization", value: basicAuth)
        
        var configuration = ClientConnection.Configuration(
            target: .hostAndPort(host, port),
            eventLoopGroup: self.eventLoopGroup,
            connectionBackoff: ConnectionBackoff(minimumConnectionTimeout: deadlineAfter, retries: .upTo(retriesLimit)),
            connectionKeepalive: ClientConnectionKeepalive(timeout: keepAliveTimeout, permitWithoutCalls: true),
            callStartBehavior: .fastFailure
        )
        
        if ssl {
            configuration.tls = .init()
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
        self.nakamaGrpcClient = Nakama_Api_NakamaClient(channel: grpcConnection, defaultCallOptions: callOptions)
    }
    
    public func disconnect() async throws -> Void {
        return try await self.grpcConnection.close().get()
    }
    
    public func createSocket(host: String?, port: Int?, ssl: Bool?) -> SocketClient {
        return self.createSocket(host: host, port: port, ssl: ssl, socketAdapter: nil)
    }
    
    public func createSocket(host: String?, port: Int?, ssl: Bool?, socketAdapter: SocketAdapter?) -> SocketClient {
        return WebSocketClient(host: host ?? self.host, port: port ?? 7350, ssl: ssl ?? self.ssl, eventLoopGroup: self.eventLoopGroup, socketAdapter: socketAdapter, logger: self.logger)
    }
    
    public func addFriends(session: Session, ids: String...) async throws -> Void {
        return try await self.addFriends(session: session, ids: ids, usernames: nil)
    }
    
    public func addFriends(session: Session, ids: [String]? = [], usernames: [String]? = []) async throws -> Void {
        var req = Nakama_Api_AddFriendsRequest()
        if ids != nil {
            req.ids = ids!
        }
        if usernames != nil {
            req.usernames = usernames!
        }
        
        _ = try await self.nakamaGrpcClient.addFriends(req, callOptions: sessionCallOption(session: session)).response.get()
    }
    
    public func addGroupUsers(session: Session, groupId: String, ids: String...) async throws -> Void {
        var req = Nakama_Api_AddGroupUsersRequest()
        req.groupID = groupId
        req.userIds = ids
        
        _ = try await self.nakamaGrpcClient.addGroupUsers(req, callOptions: sessionCallOption(session: session)).response.get()
    }
    
    public func authenticateCustom(id: String) async throws -> Session {
        return try await self.authenticateCustom(id: id, create: nil, username: nil, vars: nil)
    }
    public func authenticateCustom(id: String, create: Bool?) async throws -> Session {
        return try await self.authenticateCustom(id: id, create: nil, username: nil, vars: nil)
    }
    public func authenticateCustom(id: String, create: Bool?, username: String?) async throws -> Session {
        return try await self.authenticateCustom(id: id, create: nil, username: username, vars: nil)
    }
    public func authenticateCustom(id: String, create: Bool?, username: String?, vars: [String : String]?) async throws -> Session {
        var req = Nakama_Api_AuthenticateCustomRequest()
        req.account = Nakama_Api_AccountCustom()
        req.account.id = id
        req.create = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.create.value = create ?? true
        if username != nil {
            req.username = username!
        }
        if vars != nil {
            req.account.vars = vars!
        }
        return try await self.nakamaGrpcClient.authenticateCustom(req).response.get().toSession()
    }
    
    public func authenticateDevice(id: String) async throws -> Session {
        return try await self.authenticateDevice(id: id, create: nil, username: nil, vars: nil)
    }
    public func authenticateDevice(id: String, create: Bool?) async throws -> Session {
        return try await self.authenticateDevice(id: id, create: create, username: nil, vars: nil)
    }
    public func authenticateDevice(id: String, create: Bool?, username: String?) async throws -> Session {
        return try await self.authenticateDevice(id: id, create: nil, username: username, vars: nil)
    }
    public func authenticateDevice(id: String, create: Bool?, username: String?, vars: [String : String]?) async throws -> Session {
        var req = Nakama_Api_AuthenticateDeviceRequest()
        req.account = Nakama_Api_AccountDevice()
        req.account.id = id
        req.create = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.create.value = create ?? true
        if username != nil {
            req.username = username!
        }
        if vars != nil {
            req.account.vars = vars!
        }
        return try await self.nakamaGrpcClient.authenticateDevice(req).response.get().toSession()
    }
    
    public func authenticateEmail(email: String, password: String) async throws -> Session {
        return try await self.authenticateEmail(email: email, password: password, create: nil, username: nil, vars: nil)
    }
    public func authenticateEmail(email: String, password: String, create: Bool?) async throws -> Session {
        return try await self.authenticateEmail(email: email, password: password, create: create, username: nil, vars: nil)
    }
    public func authenticateEmail(email: String, password: String, create: Bool?, username: String?) async throws -> Session {
        return try await self.authenticateEmail(email: email, password: password, create: create, username: username, vars: nil)
    }
    public func authenticateEmail(email: String, password: String, create: Bool?, username: String?, vars: [String : String]?) async throws -> Session {
        var req = Nakama_Api_AuthenticateEmailRequest()
        req.account = Nakama_Api_AccountEmail()
        req.account.email = email
        req.account.password = password
        req.create = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.create.value = create ?? true
        if username != nil {
            req.username = username!
        }
        if vars != nil {
            req.account.vars = vars!
        }
        return try await self.nakamaGrpcClient.authenticateEmail(req).response.get().toSession()
    }

    
    public func authenticateFacebook(accessToken: String) async throws -> Session {
        return try await self.authenticateFacebook(accessToken: accessToken, create: nil, username: nil, importFriends: nil, vars: nil)
    }
    public func authenticateFacebook(accessToken: String, create: Bool?) async throws -> Session {
        return try await self.authenticateFacebook(accessToken: accessToken, create: create, username: nil, importFriends: nil, vars: nil)
    }
    public func authenticateFacebook(accessToken: String, create: Bool?, username: String?) async throws -> Session {
        return try await self.authenticateFacebook(accessToken: accessToken, create: create, username: username, importFriends: nil, vars: nil)
    }
    public func authenticateFacebook(accessToken: String, create: Bool?, username: String?, importFriends: Bool?) async throws -> Session {
        return try await self.authenticateFacebook(accessToken: accessToken, create: create, username: username, importFriends: importFriends, vars: nil)
    }
    public func authenticateFacebook(accessToken: String, create: Bool?, username: String?, importFriends: Bool?, vars: [String : String]?) async throws -> Session {
        var req = Nakama_Api_AuthenticateFacebookRequest()
        req.account = Nakama_Api_AccountFacebook()
        req.account.token = accessToken
        req.create = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.create.value = create ?? true
        if username != nil {
            req.username = username!
        }
        if vars != nil {
            req.account.vars = vars!
        }
        return try await self.nakamaGrpcClient.authenticateFacebook(req).response.get().toSession()
    }
    
    public func authenticateGoogle(accessToken: String) async throws -> Session {
        return try await self.authenticateGoogle(accessToken: accessToken, create: nil, username: nil, vars: nil)
    }
    public func authenticateGoogle(accessToken: String, create: Bool?) async throws -> Session {
        return try await self.authenticateGoogle(accessToken: accessToken, create: create, username: nil, vars: nil)
    }
    public func authenticateGoogle(accessToken: String, create: Bool?, username: String?) async throws -> Session {
        return try await self.authenticateGoogle(accessToken: accessToken, create: create, username: username, vars: nil)
    }
    public func authenticateGoogle(accessToken: String, create: Bool?, username: String?, vars: [String : String]?) async throws -> Session {
        var req = Nakama_Api_AuthenticateGoogleRequest()
        req.account = Nakama_Api_AccountGoogle()
        req.account.token = accessToken
        req.create = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.create.value = create ?? true
        if username != nil {
            req.username = username!
        }
        if vars != nil {
            req.account.vars = vars!
        }
        return try await self.nakamaGrpcClient.authenticateGoogle(req).response.get().toSession()
    }
    
    public func authenticateSteam(token: String) async throws -> Session {
        return try await self.authenticateSteam(token: token, create: nil, username: nil, vars: nil)
    }
    public func authenticateSteam(token: String, create: Bool?) async throws -> Session {
        return try await self.authenticateSteam(token: token, create: create, username: nil, vars: nil)
    }
    public func authenticateSteam(token: String, create: Bool?, username: String?) async throws -> Session {
        return try await self.authenticateSteam(token: token, create: create, username: username, vars: nil)
    }
    public func authenticateSteam(token: String, create: Bool?, username: String?, vars: [String : String]?) async throws -> Session {
        var req = Nakama_Api_AuthenticateSteamRequest()
        req.account = Nakama_Api_AccountSteam()
        req.account.token = token
        req.create = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.create.value = create ?? true
        if username != nil {
            req.username = username!
        }
        if vars != nil {
            req.account.vars = vars!
        }
        return try await self.nakamaGrpcClient.authenticateSteam(req).response.get().toSession()
    }
    
    public func authenticateApple(token: String) async throws -> Session {
        return try await self.authenticateApple(token: token, create: nil, username: nil, vars: nil)
    }
    public func authenticateApple(token: String, create: Bool?) async throws -> Session {
        return try await self.authenticateApple(token: token, create: create, username: nil, vars: nil)
    }
    public func authenticateApple(token: String, create: Bool?, username: String?) async throws -> Session {
        return try await self.authenticateApple(token: token, create: create, username: username, vars: nil)
    }
    public func authenticateApple(token: String, create: Bool?, username: String?, vars: [String : String]?) async throws -> Session {
        var req = Nakama_Api_AuthenticateAppleRequest()
        req.account = Nakama_Api_AccountApple()
        req.account.token = token
        req.create = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.create.value = create ?? true
        if username != nil {
            req.username = username!
        }
        if vars != nil {
            req.account.vars = vars!
        }
        return try await self.nakamaGrpcClient.authenticateApple(req).response.get().toSession()
    }
    
    public func authenticateFacebookInstantGame(signedPlayerInfo: String) async throws -> Session {
        return try await self.authenticateFacebookInstantGame(signedPlayerInfo: signedPlayerInfo, create: nil, username: nil, vars: nil)
    }
    public func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?) async throws -> Session {
        return try await self.authenticateFacebookInstantGame(signedPlayerInfo: signedPlayerInfo, create: create, username: nil, vars: nil)
    }
    public func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?, username: String?) async throws -> Session {
        return try await self.authenticateFacebookInstantGame(signedPlayerInfo: signedPlayerInfo, create: nil, username: username, vars: nil)
    }
    public func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?, username: String?, vars: [String : String]?) async throws -> Session {
        var req = Nakama_Api_AuthenticateFacebookInstantGameRequest()
        req.account = Nakama_Api_AccountFacebookInstantGame()
        req.account.signedPlayerInfo = signedPlayerInfo
        req.create = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.create.value = create ?? true
        if username != nil {
            req.username = username!
        }
        if vars != nil {
            req.account.vars = vars!
        }
        return try await self.nakamaGrpcClient.authenticateFacebookInstantGame(req).response.get().toSession()
    }
    
    public func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String) async throws -> Session {
        return try await self.authenticateGameCenter(playerId: playerId, bundleId: bundleId, timestampSeconds: timestampSeconds, salt: salt, signature: signature, publicKeyUrl: publicKeyUrl, create: nil, username: nil, vars: nil)
    }
    public func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?) async throws -> Session {
        return try await self.authenticateGameCenter(playerId: playerId, bundleId: bundleId, timestampSeconds: timestampSeconds, salt: salt, signature: signature, publicKeyUrl: publicKeyUrl, create: create, username: nil, vars: nil)
    }
    public func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?, username: String?) async throws -> Session {
        return try await self.authenticateGameCenter(playerId: playerId, bundleId: bundleId, timestampSeconds: timestampSeconds, salt: salt, signature: signature, publicKeyUrl: publicKeyUrl, create: nil, username: username, vars: nil)
    }
    public func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?, username: String?, vars: [String : String]?) async throws -> Session {
        var req = Nakama_Api_AuthenticateGameCenterRequest()
        req.account = Nakama_Api_AccountGameCenter()
        req.account.playerID = playerId
        req.account.bundleID = bundleId
        req.account.timestampSeconds = timestampSeconds
        req.account.salt = salt
        req.account.signature = signature
        req.account.publicKeyURL = publicKeyUrl
        req.create = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.create.value = create ?? true
        if username != nil {
            req.username = username!
        }
        if vars != nil {
            req.account.vars = vars!
        }
        return try await self.nakamaGrpcClient.authenticateGameCenter(req).response.get().toSession()
    }
    
    public func refreshSession(session: Session, vars: [String : String]) async throws -> Session {
        var req = Nakama_Api_SessionRefreshRequest()
        req.token = session.refreshToken
        req.vars = vars
        
        return try await self.nakamaGrpcClient.sessionRefresh(req, callOptions: nil).response.get().toSession()
    }
    
    public func sessionLogout(session: Session) async throws {
        var req = Nakama_Api_SessionLogoutRequest()
        req.token = session.token
        req.refreshToken = session.refreshToken
        
        _ = try await self.nakamaGrpcClient.sessionLogout(req, callOptions: sessionCallOption(session: session)).response.get()
    }
    
    public func writeStorageObjects(session: Session, objects: [WriteStorageObject]) async throws -> StorageObjectAcks {
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
        return try await self.nakamaGrpcClient.writeStorageObjects(req, callOptions: sessionCallOption(session: session)).response.get().toStorageObjectAcks()
    }
    
    public func readStorageObjects(session: Session, ids: [StorageObjectId]) async throws -> [StorageObject] {
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
        return try await self.nakamaGrpcClient.readStorageObjects(req, callOptions: sessionCallOption(session: session)).response.get().objects.map { $0.toStorageObject()}
    }
    
    public func deleteStorageObjects(session: Session, ids: [StorageObjectId]) async throws -> Void {
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
        _ = try await self.nakamaGrpcClient.deleteStorageObjects(req, callOptions: sessionCallOption(session: session)).response.get()
    }
    
    public func listStorageObjects(session: Session, collection: String) async throws -> StorageObjectList {
        return try await self.listStorageObjects(session: session, collection: collection, cursor: nil)
    }
    
    public func listStorageObjects(session: Session, collection: String, limit: Int = 1, cursor: String?) async throws -> StorageObjectList {
        var req = Nakama_Api_ListStorageObjectsRequest()
        req.collection = collection
        req.userID = session.userId
        req.limit = limit.pbInt32Value
        req.cursor = cursor ?? ""
        
        return try await nakamaGrpcClient.listStorageObjects(req, callOptions: sessionCallOption(session: session)).response.get().toStorageObjectList()
    }
    
}

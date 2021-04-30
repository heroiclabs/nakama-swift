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
import NIOSSL
import NIOHPACK
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
    
    func mapEmptyVoid() -> (SwiftProtobuf.Google_Protobuf_Empty) -> EventLoopFuture<Void> {
        return { (Google_Protobuf_Empty) -> EventLoopFuture<Void> in
            return self.eventLoopGroup.next().submit { () -> Void in
                return Void()
            }
        }
    }
    
    func mapSession() -> (Nakama_Api_Session) -> EventLoopFuture<Session> {
        return { (apiSession: Nakama_Api_Session) -> EventLoopFuture<Session> in
            return self.eventLoopGroup.next().submit { () -> Session in
                return DefaultSession(token: apiSession.token, created: apiSession.created)
            }
        }
    }
    
    func mapGroups() -> (Nakama_Api_Group) -> EventLoopFuture<Nakama_Api_Group>{
        return { (groupList: Nakama_Api_Group) -> EventLoopFuture<Nakama_Api_Group> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_Group in
                return groupList
            }
        }
    }
    
     func mapGroupsList() -> (Nakama_Api_GroupList) -> EventLoopFuture<Nakama_Api_GroupList> {
        return { (groupsList : Nakama_Api_GroupList ) -> EventLoopFuture<Nakama_Api_GroupList> in
            return self.eventLoopGroup.next().submit{ () -> Nakama_Api_GroupList in
                return groupsList
            }
        }
    }
    
    func mapUsers() -> (Nakama_Api_Users) -> EventLoopFuture<Nakama_Api_Users>{
        return { (apiUsers : Nakama_Api_Users) -> EventLoopFuture<Nakama_Api_Users> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_Users in
                return apiUsers
            }
        }
    }
    
    func mapFriendListUsers() -> (Nakama_Api_FriendList) -> EventLoopFuture<Nakama_Api_FriendList>{
        return { (apiUsers : Nakama_Api_FriendList) -> EventLoopFuture<Nakama_Api_FriendList> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_FriendList in
                return apiUsers
            }
        }
    }
    
    func mapMatchList() -> (Nakama_Api_MatchList) -> EventLoopFuture<Nakama_Api_MatchList>{
        return { (apiMatches : Nakama_Api_MatchList) -> EventLoopFuture<Nakama_Api_MatchList> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_MatchList in
                return apiMatches
            }
        }
    }
    
    func mapChannelMessageList() -> (Nakama_Api_ChannelMessageList) -> EventLoopFuture<Nakama_Api_ChannelMessageList>{
        return { (apiChannelMessageList : Nakama_Api_ChannelMessageList) -> EventLoopFuture<Nakama_Api_ChannelMessageList> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_ChannelMessageList in
                return apiChannelMessageList
            }
        }
    }
    
    func mapLeaderBoardList() -> (Nakama_Api_LeaderboardRecordList) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList>{
        return { (apiLeaderBoardList : Nakama_Api_LeaderboardRecordList) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_LeaderboardRecordList in
                return apiLeaderBoardList
            }
        }
    }
    
    func mapStorageObjectList() -> (Nakama_Api_StorageObjectList) -> EventLoopFuture<Nakama_Api_StorageObjectList>{
        return { (apiStorageList : Nakama_Api_StorageObjectList) -> EventLoopFuture<Nakama_Api_StorageObjectList> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_StorageObjectList in
                return apiStorageList
            }
        }
    }
    
    func mapListTournaments() -> (Nakama_Api_TournamentList) -> EventLoopFuture<Nakama_Api_TournamentList>{
        return { (apiTournamentsList : Nakama_Api_TournamentList) -> EventLoopFuture<Nakama_Api_TournamentList> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_TournamentList in
                return apiTournamentsList
            }
        }
    }
    
    func mapStorageObjects() -> (Nakama_Api_StorageObjects) -> EventLoopFuture<Nakama_Api_StorageObjects>{
        return { (apiStorageObjects : Nakama_Api_StorageObjects) -> EventLoopFuture<Nakama_Api_StorageObjects> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_StorageObjects in
                return apiStorageObjects
            }
        }
    }
    
    func mapLeaderBoardRecord() -> (Nakama_Api_LeaderboardRecord) -> EventLoopFuture<Nakama_Api_LeaderboardRecord>{
        return { (api : Nakama_Api_LeaderboardRecord) -> EventLoopFuture<Nakama_Api_LeaderboardRecord> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_LeaderboardRecord in
                return api
            }
        }
    }
    
    func mapApiRpc() -> (Nakama_Api_Rpc) -> EventLoopFuture<Nakama_Api_Rpc>{
        return { (api : Nakama_Api_Rpc) -> EventLoopFuture<Nakama_Api_Rpc> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_Rpc in 
                return api
            }
        }
    }
    
    // map Nakama_Api_NotificationList
    func mapApiNotificaionList() -> (Nakama_Api_NotificationList) -> EventLoopFuture<Nakama_Api_NotificationList>{
        return { (api : Nakama_Api_NotificationList) -> EventLoopFuture<Nakama_Api_NotificationList> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_NotificationList in
                return api
            }
        }
    }
    
    // map Nakama_Api_TournamentRecordList
    func mapApiTournamentList() -> (Nakama_Api_TournamentRecordList) -> EventLoopFuture<Nakama_Api_TournamentRecordList>{
        return { (api : Nakama_Api_TournamentRecordList) -> EventLoopFuture<Nakama_Api_TournamentRecordList> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_TournamentRecordList in
                return api
            }
        }
    }
    
    // map Nakama_Api_UserGroupList
    func mapApiUserGroupList() -> (Nakama_Api_UserGroupList) -> EventLoopFuture<Nakama_Api_UserGroupList>{
        return { (api : Nakama_Api_UserGroupList) -> EventLoopFuture<Nakama_Api_UserGroupList> in
            return self.eventLoopGroup.next().submit { () -> Nakama_Api_UserGroupList in
                return api
            }
        }
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
    
    public func disconnect() -> EventLoopFuture<Void> {
        return self.grpcConnection.close()
    }
    
    public func createSocket(host: String?, port: Int?, ssl: Bool?) -> SocketClient {
        return self.createSocket(host: host, port: port, ssl: ssl, socketAdapter: nil)
    }
    
    public func createSocket(host: String?, port: Int?, ssl: Bool?, socketAdapter: SocketAdapter?) -> SocketClient {
        return WebSocketClient(host: host ?? self.host, port: port ?? 7350, ssl: ssl ?? self.ssl, eventLoopGroup: self.eventLoopGroup, socketAdapter: socketAdapter, logger: self.logger)
    }
    
    public func addFriends(session: Session, ids: String...) -> EventLoopFuture<Void> {
        return self.addFriends(session: session, ids: ids, usernames: nil)
    }
    
    public func addFriends(session: Session, ids: [String]? = [], usernames: [String]? = []) -> EventLoopFuture<Void> {
        var req = Nakama_Api_AddFriendsRequest()
        if ids != nil {
            req.ids = ids!
        }
        if usernames != nil {
            req.usernames = usernames!
        }
        return self.nakamaGrpcClient.addFriends(req, callOptions: sessionCallOption(session: session)).response.flatMap(mapEmptyVoid())
    }
    
    public func addGroupUsers(session: Session, groupId: String, ids: String...) -> EventLoopFuture<Void> {
        var req = Nakama_Api_AddGroupUsersRequest()
        req.groupID = groupId
        req.userIds = ids
        return self.nakamaGrpcClient.addGroupUsers(req, callOptions: sessionCallOption(session: session)).response.flatMap(mapEmptyVoid())
    }
    
    public func authenticateCustom(id: String) -> EventLoopFuture<Session> {
        return self.authenticateCustom(id: id, create: nil, username: nil, vars: nil)
    }
    public func authenticateCustom(id: String, create: Bool?) -> EventLoopFuture<Session> {
        return self.authenticateCustom(id: id, create: nil, username: nil, vars: nil)
    }
    public func authenticateCustom(id: String, create: Bool?, username: String?) -> EventLoopFuture<Session> {
        return self.authenticateCustom(id: id, create: nil, username: username, vars: nil)
    }
    public func authenticateCustom(id: String, create: Bool?, username: String?, vars: [String : String]?) -> EventLoopFuture<Session> {
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
        return self.nakamaGrpcClient.authenticateCustom(req).response.flatMap(mapSession())
    }
    
    public func authenticateDevice(id: String) -> EventLoopFuture<Session> {
        return self.authenticateDevice(id: id, create: nil, username: nil, vars: nil)
    }
    public func authenticateDevice(id: String, create: Bool?) -> EventLoopFuture<Session> {
        return self.authenticateDevice(id: id, create: create, username: nil, vars: nil)
    }
    public func authenticateDevice(id: String, create: Bool?, username: String?) -> EventLoopFuture<Session> {
        return self.authenticateDevice(id: id, create: nil, username: username, vars: nil)
    }
    public func authenticateDevice(id: String, create: Bool?, username: String?, vars: [String : String]?) -> EventLoopFuture<Session> {
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
        return self.nakamaGrpcClient.authenticateDevice(req).response.flatMap(mapSession())
    }
    
    public func authenticateEmail(email: String, password: String) -> EventLoopFuture<Session> {
        return self.authenticateEmail(email: email, password: password, create: nil, username: nil, vars: nil)
    }
    public func authenticateEmail(email: String, password: String, create: Bool?) -> EventLoopFuture<Session> {
        return self.authenticateEmail(email: email, password: password, create: create, username: nil, vars: nil)
    }
    public func authenticateEmail(email: String, password: String, create: Bool?, username: String?) -> EventLoopFuture<Session> {
        return self.authenticateEmail(email: email, password: password, create: create, username: username, vars: nil)
    }
    public func authenticateEmail(email: String, password: String, create: Bool?, username: String?, vars: [String : String]?) -> EventLoopFuture<Session> {
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
        return self.nakamaGrpcClient.authenticateEmail(req).response.flatMap(mapSession())
    }

    
    public func authenticateFacebook(accessToken: String) -> EventLoopFuture<Session> {
        return self.authenticateFacebook(accessToken: accessToken, create: nil, username: nil, importFriends: nil, vars: nil)
    }
    public func authenticateFacebook(accessToken: String, create: Bool?) -> EventLoopFuture<Session> {
        return self.authenticateFacebook(accessToken: accessToken, create: create, username: nil, importFriends: nil, vars: nil)
    }
    public func authenticateFacebook(accessToken: String, create: Bool?, username: String?) -> EventLoopFuture<Session> {
        return self.authenticateFacebook(accessToken: accessToken, create: create, username: username, importFriends: nil, vars: nil)
    }
    public func authenticateFacebook(accessToken: String, create: Bool?, username: String?, importFriends: Bool?) -> EventLoopFuture<Session> {
        return self.authenticateFacebook(accessToken: accessToken, create: create, username: username, importFriends: importFriends, vars: nil)
    }
    public func authenticateFacebook(accessToken: String, create: Bool?, username: String?, importFriends: Bool?, vars: [String : String]?) -> EventLoopFuture<Session> {
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
        return self.nakamaGrpcClient.authenticateFacebook(req).response.flatMap(mapSession())
    }
    
    public func authenticateGoogle(accessToken: String) -> EventLoopFuture<Session> {
        return self.authenticateGoogle(accessToken: accessToken, create: nil, username: nil, vars: nil)
    }
    public func authenticateGoogle(accessToken: String, create: Bool?) -> EventLoopFuture<Session> {
        return self.authenticateGoogle(accessToken: accessToken, create: create, username: nil, vars: nil)
    }
    public func authenticateGoogle(accessToken: String, create: Bool?, username: String?) -> EventLoopFuture<Session> {
        return self.authenticateGoogle(accessToken: accessToken, create: create, username: username, vars: nil)
    }
    public func authenticateGoogle(accessToken: String, create: Bool?, username: String?, vars: [String : String]?) -> EventLoopFuture<Session> {
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
        return self.nakamaGrpcClient.authenticateGoogle(req).response.flatMap(mapSession())
    }
    
    public func authenticateSteam(token: String) -> EventLoopFuture<Session> {
        return self.authenticateSteam(token: token, create: nil, username: nil, vars: nil)
    }
    public func authenticateSteam(token: String, create: Bool?) -> EventLoopFuture<Session> {
        return self.authenticateSteam(token: token, create: create, username: nil, vars: nil)
    }
    public func authenticateSteam(token: String, create: Bool?, username: String?) -> EventLoopFuture<Session> {
        return self.authenticateSteam(token: token, create: create, username: username, vars: nil)
    }
    public func authenticateSteam(token: String, create: Bool?, username: String?, vars: [String : String]?) -> EventLoopFuture<Session> {
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
        return self.nakamaGrpcClient.authenticateSteam(req).response.flatMap(mapSession())
    }
    
    public func authenticateApple(token: String) -> EventLoopFuture<Session> {
        return self.authenticateApple(token: token, create: nil, username: nil, vars: nil)
    }
    public func authenticateApple(token: String, create: Bool?) -> EventLoopFuture<Session> {
        return self.authenticateApple(token: token, create: create, username: nil, vars: nil)
    }
    public func authenticateApple(token: String, create: Bool?, username: String?) -> EventLoopFuture<Session> {
        return self.authenticateApple(token: token, create: create, username: username, vars: nil)
    }
    public func authenticateApple(token: String, create: Bool?, username: String?, vars: [String : String]?) -> EventLoopFuture<Session> {
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
        return self.nakamaGrpcClient.authenticateApple(req).response.flatMap(mapSession())
    }
    
    public func authenticateFacebookInstantGame(signedPlayerInfo: String) -> EventLoopFuture<Session> {
        return self.authenticateFacebookInstantGame(signedPlayerInfo: signedPlayerInfo, create: nil, username: nil, vars: nil)
    }
    public func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?) -> EventLoopFuture<Session> {
        return self.authenticateFacebookInstantGame(signedPlayerInfo: signedPlayerInfo, create: create, username: nil, vars: nil)
    }
    public func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?, username: String?) -> EventLoopFuture<Session> {
        return self.authenticateFacebookInstantGame(signedPlayerInfo: signedPlayerInfo, create: nil, username: username, vars: nil)
    }
    public func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?, username: String?, vars: [String : String]?) -> EventLoopFuture<Session> {
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
        return self.nakamaGrpcClient.authenticateFacebookInstantGame(req).response.flatMap(mapSession())
    }
    
    public func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String) -> EventLoopFuture<Session> {
        return self.authenticateGameCenter(playerId: playerId, bundleId: bundleId, timestampSeconds: timestampSeconds, salt: salt, signature: signature, publicKeyUrl: publicKeyUrl, create: nil, username: nil, vars: nil)
    }
    public func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?) -> EventLoopFuture<Session> {
        return self.authenticateGameCenter(playerId: playerId, bundleId: bundleId, timestampSeconds: timestampSeconds, salt: salt, signature: signature, publicKeyUrl: publicKeyUrl, create: create, username: nil, vars: nil)
    }
    public func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?, username: String?) -> EventLoopFuture<Session> {
        return self.authenticateGameCenter(playerId: playerId, bundleId: bundleId, timestampSeconds: timestampSeconds, salt: salt, signature: signature, publicKeyUrl: publicKeyUrl, create: nil, username: username, vars: nil)
    }
    public func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?, username: String?, vars: [String : String]?) -> EventLoopFuture<Session> {
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
        return self.nakamaGrpcClient.authenticateGameCenter(req).response.flatMap(mapSession())
    }
    
    public func banGroupUsers(session: Session, groupId: String, ids : String... ) -> EventLoopFuture<Void> {
        var req = Nakama_Api_BanGroupUsersRequest.init()
        req.userIds = ids
        req.groupID = groupId
        return self.nakamaGrpcClient.banGroupUsers( req, callOptions: sessionCallOption(session: session)).response.flatMap(mapEmptyVoid())
    }
    
    
    public func blockFriends(session: Session, ids: String...) -> EventLoopFuture<Void> {
        return self.blockFriends(session: session, ids: ids , usernames: nil)
    }
    
    public func blockFriends(session: Session, ids: [ String ]?, usernames: [String]? ) -> EventLoopFuture<Void> {
        var req         = Nakama_Api_BlockFriendsRequest.init()
        if ids != nil{
            req.ids         = ids!
        }
        if usernames != nil {
            req.usernames   = usernames!
        }
        return self.nakamaGrpcClient.blockFriends( req , callOptions: sessionCallOption(session: session)).response.flatMap(mapEmptyVoid())
    }
    
    public func createGroup(session: Session, name: String) -> EventLoopFuture< Nakama_Api_Group > {
        return self.createGroup(session: session, name: name, description: nil, avatarUrl: nil, langTag: nil, open: nil, maxCount: nil)
    }
    
    public func createGroup(session: Session, name: String?, description: String?) -> EventLoopFuture< Nakama_Api_Group > {
        return self.createGroup(session: session, name: name, description: description, avatarUrl: nil, langTag: nil, open: nil, maxCount: nil)
    }
    
    public func createGroup(session: Session, name: String?, description: String?, avatarUrl: String?) -> EventLoopFuture< Nakama_Api_Group > {
        return self.createGroup(session: session, name: name, description: description, avatarUrl: avatarUrl, langTag: nil, open: nil, maxCount: nil)
    }
    
    public func createGroup(session: Session, name: String?, description: String?, avatarUrl: String?, langTag: String?) -> EventLoopFuture< Nakama_Api_Group > {
        return self.createGroup(session: session, name: name, description: description, avatarUrl: avatarUrl, langTag: langTag, open: nil, maxCount: nil)
    }
    
    public func createGroup(session: Session, name: String?, description: String?, avatarUrl: String?, langTag: String?, open: Bool?) -> EventLoopFuture< Nakama_Api_Group > {
        return self.createGroup(session: session, name: name, description: description, avatarUrl: avatarUrl, langTag: langTag, open: open, maxCount: nil)
    }
    
    public func createGroup(session: Session, name: String?, description: String?, avatarUrl: String?, langTag: String?, open: Bool?, maxCount: Int32?) -> EventLoopFuture< Nakama_Api_Group > {
        var req         = Nakama_Api_CreateGroupRequest.init()
        if name != nil{
            req.name         = name!
        }
        if description != nil {
            req.description_p   = description!
        }
        if avatarUrl != nil {
            req.avatarURL = avatarUrl!
        }
        if langTag != nil {
            req.langTag = langTag!
        }
        if open != nil {
            req.open = open!
        }
        if maxCount != nil {
            req.maxCount = maxCount!
        }
        return self.nakamaGrpcClient.createGroup( req , callOptions: sessionCallOption(session: session)).response.flatMap( mapGroups() )
    }

    public func deleteFriends(session: Session, ids: String...) -> EventLoopFuture<Void> {
        return self.deleteFriends(session: session, ids: ids, usernames: nil)
    }
    
    public func deleteFriends(session: Session, ids: [String]?, usernames: [String]?) -> EventLoopFuture<Void> {
        var req         = Nakama_Api_DeleteFriendsRequest.init()
        if ids != nil{
            req.ids         = ids!
        }
        if usernames != nil {
            req.usernames = usernames!
        }
        return self.nakamaGrpcClient.deleteFriends( req , callOptions: sessionCallOption(session: session)).response.flatMap( mapEmptyVoid() )
    }
    
    public func deleteGroup(session: Session, groupId: String) -> EventLoopFuture<Void> {
        var req         = Nakama_Api_DeleteGroupRequest.init()
        req.groupID     = groupId
        return self.nakamaGrpcClient.deleteGroup( req , callOptions: sessionCallOption(session: session)).response.flatMap( mapEmptyVoid() )
    }
    
    public func deleteLeaderboardRecord(session: Session, leaderboardId: String) -> EventLoopFuture<Void> {
        var req         = Nakama_Api_DeleteLeaderboardRecordRequest.init()
        req.leaderboardID     = leaderboardId
        return self.nakamaGrpcClient.deleteLeaderboardRecord( req , callOptions: sessionCallOption(session: session)).response.flatMap( mapEmptyVoid() )
    }
    
    public func deleteNotifications(session: Session, notificationIds: String...) -> EventLoopFuture<Void> {
        var req     = Nakama_Api_DeleteNotificationsRequest.init()
        req.ids     = notificationIds
        return self.nakamaGrpcClient.deleteNotifications( req , callOptions: sessionCallOption(session: session)).response.flatMap( mapEmptyVoid() )
    }
    
    public func demoteGroupUsers(session: Session, groupId: String, userIds: String...) -> EventLoopFuture<Void> {
        var req = Nakama_Api_DemoteGroupUsersRequest.init()
        req.groupID = groupId
        req.userIds = userIds
        return self.nakamaGrpcClient.demoteGroupUsers( req , callOptions: sessionCallOption(session: session)).response.flatMap( mapEmptyVoid() )
    }
    
    /*public func emitEvent(session: Session, name: String, properties: [String : String]) -> EventLoopFuture<Void> {
        
    }*/
    
    /*public func getAccount(session: Session) -> EventLoopFuture<Nakama_Api_Account> {
        var req = Nakama_Api_UpdateAccountRequest.init()
        
    }*/
    
    public func getUsers(session: Session, ids: String...) -> EventLoopFuture<Nakama_Api_Users> {
        return self.getUsers(session: session, ids: ids, usernames: nil, facebookIds: nil)
    }
    
    public func getUsers(session: Session, ids: [String]?, usernames: [String]?) -> EventLoopFuture<Nakama_Api_Users> {
        return self.getUsers(session: session, ids: ids, usernames: usernames, facebookIds: nil)
    }
    
    public func getUsers(session: Session, ids: [String]?, usernames: [String]?, facebookIds: [String]?) -> EventLoopFuture<Nakama_Api_Users> {
        var req = Nakama_Api_GetUsersRequest.init()
        if ids != nil{
            req.ids = ids!
        }
        if usernames != nil{
            req.ids = ids!
        }
        return self.nakamaGrpcClient.getUsers( req, callOptions: sessionCallOption(session: session) ).response.flatMap( mapUsers() )
    }
    
    public func importFacebookFriends(session: Session, token: String) -> EventLoopFuture<Void> {
        return self.importFacebookFriends(session: session, token: token, reset: nil)
    }
    
    public func importFacebookFriends(session: Session, token: String?, reset: Bool? ) -> EventLoopFuture<Void> {
        var req         = Nakama_Api_ImportFacebookFriendsRequest.init()
        req.account     = Nakama_Api_AccountFacebook.init()
        if token != nil {
            req.account.token = token!
        }
        //
        req.reset       = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.reset.value = reset ?? true
        //
        return self.nakamaGrpcClient.importFacebookFriends(req, callOptions: sessionCallOption(session: session) ).response.flatMap( mapEmptyVoid() )
    
    }
    
    public func joinGroup(session: Session, groupId: String) -> EventLoopFuture<Void> {
        var req = Nakama_Api_JoinGroupRequest.init()
        return self.nakamaGrpcClient.joinGroup(req, callOptions: sessionCallOption(session: session) ).response.flatMap( mapEmptyVoid() )
    }
    
    public func joinTournament(session: Session, tournamentId: String) -> EventLoopFuture<Void> {
        var req             = Nakama_Api_JoinTournamentRequest.init()
        req.tournamentID    = tournamentId
        return self.nakamaGrpcClient.joinTournament(req, callOptions: sessionCallOption(session: session) ).response.flatMap( mapEmptyVoid() )
    }
    
    public func kickGroupUsers(session: Session, groupId: String, ids: String...) -> EventLoopFuture<Void> {
        var req     = Nakama_Api_KickGroupUsersRequest.init()
        req.groupID = groupId
        req.userIds = ids
        return self.nakamaGrpcClient.kickGroupUsers(req, callOptions: sessionCallOption(session: session) ).response.flatMap( mapEmptyVoid() )
    }
    
    public func leaveGroup(session: Session, groupId: String) -> EventLoopFuture<Void> {
        var req     = Nakama_Api_LeaveGroupRequest.init()
        req.groupID = groupId
        return self.nakamaGrpcClient.leaveGroup( req, callOptions: sessionCallOption(session: session) ).response.flatMap( mapEmptyVoid() )
    }
    
    /*public func linkApple(session: Session, token: String) -> EventLoopFuture<Void> {
        var req = NakamaLinkApp
    }*/
    
    /*public func linkCustom(session: Session, id: String) -> EventLoopFuture<Void> {
        var req = NakamaLink
    }
    
    public func linkDevice(session: Session, id: String) -> EventLoopFuture<Void> {
        
    }*/
    
    
    public func listGroups(session: Session, name: String) -> EventLoopFuture<Nakama_Api_GroupList> {
        return self.listGroups(session: session, name: name, limit: nil, cursor: nil)
    }
    
    public func listGroups(session: Session, name: String?, limit: Int32?) -> EventLoopFuture<Nakama_Api_GroupList> {
        return self.listGroups(session: session, name: name, limit: limit, cursor: nil)
    }
    
    public func listGroups(session: Session, name: String?, limit: Int32?, cursor: String?) -> EventLoopFuture<Nakama_Api_GroupList> {
        var req = Nakama_Api_ListGroupsRequest.init()
        if name != nil {
            req.name = name!
        }
        //
        req.limit       = SwiftProtobuf.Google_Protobuf_Int32Value()
        if limit != nil{
            req.limit.value = limit!
        }
        //
        if cursor != nil {
            req.cursor = cursor!
        }
        //self.nakamaGrpcClient.listGroups()
        return self.nakamaGrpcClient.listGroups( req , callOptions: sessionCallOption(session: session) ).response.flatMap( mapGroupsList() )
        //
    }
    
    public func listFriends(session: Session) -> EventLoopFuture<Nakama_Api_FriendList> {
        return self.listFriends(session: session, state: nil, limit: nil, cursor: nil)
    }
    
    public func listFriends(session: Session, state: Int32?, limit: Int32?, cursor: String?) -> EventLoopFuture<Nakama_Api_FriendList> {
        var req = Nakama_Api_ListFriendsRequest.init()
        req.state = SwiftProtobuf.Google_Protobuf_Int32Value()
        if state != nil {
            req.state.value = state!
        }
        req.limit = SwiftProtobuf.Google_Protobuf_Int32Value()
        if limit != nil {
            req.limit.value = limit!
        }
        if cursor != nil {
            req.cursor = cursor!
        }
        return self.nakamaGrpcClient.listFriends(req, callOptions: sessionCallOption(session: session) ).response.flatMap( mapFriendListUsers() )
    }
    
    public func listMatches(session: Session) -> EventLoopFuture<Nakama_Api_MatchList> {
        return self.listMatches(session: session, min: nil, max: nil, limit: nil, label: nil, authoritative: nil)
    }
    
    public func listMatches(session: Session, min: Int32?) -> EventLoopFuture<Nakama_Api_MatchList> {
        return self.listMatches(session: session, min: min, max: nil, limit: nil, label: nil, authoritative: nil)
    }
    
    public func listMatches(session: Session, min: Int32?, max: Int32?) -> EventLoopFuture<Nakama_Api_MatchList> {
        return self.listMatches(session: session, min: min, max: max, limit: nil, label: nil, authoritative: nil)
    }
    
    public func listMatches(session: Session, min: Int32?, max: Int32?, limit: Int32?) -> EventLoopFuture<Nakama_Api_MatchList> {
        return self.listMatches(session: session, min: min, max: max, limit: limit, label: nil, authoritative: nil)
    }
    
    public func listMatches(session: Session, min: Int32?, max: Int32?, limit: Int32?, label: String?) -> EventLoopFuture<Nakama_Api_MatchList> {
        return self.listMatches(session: session, min: min, max: max, limit: limit, label: label, authoritative: nil)
    }
    
    public func listMatches(session: Session, min: Int32?, max: Int32?, limit: Int32?, label: String?, authoritative: Bool?) -> EventLoopFuture<Nakama_Api_MatchList> {
        var req = Nakama_Api_ListMatchesRequest.init()
        req.authoritative = SwiftProtobuf.Google_Protobuf_BoolValue()
        if authoritative != nil {
            req.authoritative.value = authoritative!
        }
        //
        req.label = SwiftProtobuf.Google_Protobuf_StringValue()
        if label != nil {
            req.label.value = label!
        }
        req.maxSize = SwiftProtobuf.Google_Protobuf_Int32Value()
        if max != nil {
            req.maxSize.value = max!
        }
        req.minSize = SwiftProtobuf.Google_Protobuf_Int32Value()
        if min != nil {
            req.minSize.value = min!
        }
        req.limit = SwiftProtobuf.Google_Protobuf_Int32Value()
        if limit != nil {
            req.minSize.value = limit!
        }
        return self.nakamaGrpcClient.listMatches(req , callOptions: sessionCallOption(session: session)).response.flatMap( mapMatchList() )
    }
    
    
    public func listChannelMessages(session: Session, channelId: String) -> EventLoopFuture<Nakama_Api_ChannelMessageList> {
        return self.listChannelMessages(session: session, channelId: channelId, limit: nil, cursor: nil, forward: nil)
    }
    
    public func listChannelMessages(session: Session, channelId: String?, limit: Int32?) -> EventLoopFuture<Nakama_Api_ChannelMessageList> {
        return self.listChannelMessages(session: session, channelId: channelId, limit: limit, cursor: nil, forward: nil)
    }
    
    public func listChannelMessages(session: Session, channelId: String?, limit: Int32?, cursor: String?) -> EventLoopFuture<Nakama_Api_ChannelMessageList> {
        return self.listChannelMessages(session: session, channelId: channelId, limit: limit, cursor: cursor,  forward: nil)
    }
    
    public func listChannelMessages(session: Session, channelId: String?, limit: Int32?, cursor: String?, forward: Bool?) -> EventLoopFuture<Nakama_Api_ChannelMessageList> {
        var req = Nakama_Api_ListChannelMessagesRequest.init()
        if channelId != nil {
            req.channelID = channelId!
        }
        req.limit = SwiftProtobuf.Google_Protobuf_Int32Value()
        if limit != nil {
            req.limit.value = limit!
        }
        if cursor != nil {
            req.cursor = cursor!
        }
        req.forward = SwiftProtobuf.Google_Protobuf_BoolValue()
        if forward != nil {
            req.forward.value = forward!
        }
        return self.nakamaGrpcClient.listChannelMessages(req, callOptions: sessionCallOption(session: session)).response.flatMap( mapChannelMessageList() )
    }
    
    public func listLeaderboardRecords(session: Session, leaderboardId: String) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList> {
        return self.listLeaderboardRecords(session: session, leaderboardId: leaderboardId, ownerIds: nil, expiry: nil, limit: nil, cursor: nil)
    }
    
    public func listLeaderboardRecords(session: Session, leaderboardId: String?, ownerIds: [String]?) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList> {
        return self.listLeaderboardRecords(session: session, leaderboardId: leaderboardId, ownerIds: ownerIds, expiry: nil, limit: nil, cursor: nil)
    }
    
    public func listLeaderboardRecords(session: Session, leaderboardId: String?, ownerIds: [String]?, expiry: Int64?) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList> {
        return self.listLeaderboardRecords(session: session, leaderboardId: leaderboardId, ownerIds: ownerIds, expiry: expiry, limit: nil, cursor: nil)
    }
    
    public func listLeaderboardRecords(session: Session, leaderboardId: String?, ownerIds: [String]?, expiry: Int64?, limit: Int32?) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList> {
        return self.listLeaderboardRecords(session: session, leaderboardId: leaderboardId, ownerIds: ownerIds, expiry: expiry, limit: limit, cursor: nil)
    }
    
    public func listLeaderboardRecords(session: Session, leaderboardId: String?, ownerIds: [String]?, expiry: Int64?, limit: Int32?, cursor: String?) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList> {
        var req = Nakama_Api_ListLeaderboardRecordsRequest.init()
        if leaderboardId != nil {
            req.leaderboardID = leaderboardId!
        }
        if ownerIds != nil {
            req.ownerIds = ownerIds!
        }
        req.expiry = SwiftProtobuf.Google_Protobuf_Int64Value()
        if expiry != nil {
            req.expiry.value = expiry!
        }
        req.limit = SwiftProtobuf.Google_Protobuf_Int32Value()
        if limit != nil {
            req.limit.value = limit!
        }
        if cursor != nil {
            req.cursor = cursor!
        }
        return self.nakamaGrpcClient.listLeaderboardRecords(req, callOptions: sessionCallOption(session: session)).response.flatMap( mapLeaderBoardList() )
    }
    
    public func listStorageObjects(session: Session, collection: String) -> EventLoopFuture<Nakama_Api_StorageObjectList> {
        return self.listStorageObjects(session: session, collection: collection, limit: nil, cursor: nil)
    }
    
    public func listStorageObjects(session: Session, collection: String?, limit: Int32?) -> EventLoopFuture<Nakama_Api_StorageObjectList> {
        return self.listStorageObjects(session: session, collection: collection, limit: limit, cursor: nil)
    }
    
    public func listStorageObjects(session: Session, collection: String?, limit: Int32?, cursor: String?) -> EventLoopFuture<Nakama_Api_StorageObjectList> {
        var req = Nakama_Api_ListStorageObjectsRequest.init()
        if collection != nil {
            req.collection = collection!
        }
        req.limit = SwiftProtobuf.Google_Protobuf_Int32Value()
        if limit != nil {
            req.limit.value = limit!
        }
        if cursor != nil {
            req.cursor = cursor!
        }
        return self.nakamaGrpcClient.listStorageObjects(req, callOptions: sessionCallOption(session: session)).response.flatMap( mapStorageObjectList() )
    }

    public func listTournaments(session: Session) -> EventLoopFuture<Nakama_Api_TournamentList> {
        return self.listTournaments(session: session, limit: nil, cursor: nil)
    }
    
    public func listTournaments(session: Session, limit: Int32?, cursor: String?) -> EventLoopFuture<Nakama_Api_TournamentList> {
        var req = Nakama_Api_ListTournamentsRequest.init()
        req.limit = Google_Protobuf_Int32Value()
        if limit != nil {
            req.limit.value = limit!
        }
        if cursor != nil {
            req.cursor = cursor!
        }
        return self.nakamaGrpcClient.listTournaments(req, callOptions: sessionCallOption(session: session)).response.flatMap( mapListTournaments() )
    }
    
    public func listTournaments(session: Session, categoryStart: UInt32?) -> EventLoopFuture<Nakama_Api_TournamentList> {
        return self.listTournaments(session: session, categoryStart: categoryStart, categoryEnd: nil, startTime: nil, endTime: nil, cursor: nil)
    }
    
    public func listTournaments(session: Session, categoryStart: UInt32?, categoryEnd: UInt32?) -> EventLoopFuture<Nakama_Api_TournamentList> {
        return self.listTournaments(session: session, categoryStart: categoryStart, categoryEnd: categoryEnd, startTime: nil, endTime: nil, cursor: nil)
    }
    
    public func listTournaments(session: Session, categoryStart: UInt32?, categoryEnd: UInt32?, startTime: UInt32?) -> EventLoopFuture<Nakama_Api_TournamentList> {
        return self.listTournaments(session: session, categoryStart: categoryStart, categoryEnd: categoryEnd, startTime: startTime, endTime: nil, cursor: nil)
    }
    
    public func listTournaments(session: Session, categoryStart: UInt32?, categoryEnd: UInt32?, startTime: UInt32?, endTime: UInt32?) -> EventLoopFuture<Nakama_Api_TournamentList> {
        return self.listTournaments(session: session, categoryStart: categoryStart, categoryEnd: categoryEnd, startTime: startTime, endTime: endTime, cursor: nil)
    }
    
    public func listTournaments(session: Session, categoryStart: UInt32?, categoryEnd: UInt32?, startTime: UInt32?, endTime: UInt32?, cursor: String?) -> EventLoopFuture<Nakama_Api_TournamentList> {
        var req = Nakama_Api_ListTournamentsRequest.init()
        req.categoryStart = Google_Protobuf_UInt32Value()
        if categoryStart != nil {
            req.categoryStart.value = categoryStart!
        }
        req.categoryEnd = Google_Protobuf_UInt32Value()
        if categoryEnd != nil {
            req.categoryEnd.value = categoryEnd!
        }
        if cursor != nil {
            req.cursor = cursor!
        }
        req.startTime = Google_Protobuf_UInt32Value()
        if startTime != nil {
            req.startTime.value = startTime!
        }
        req.endTime = Google_Protobuf_UInt32Value()
        if endTime != nil {
            req.endTime.value = endTime!
        }
        //
        return self.nakamaGrpcClient.listTournaments(req, callOptions: sessionCallOption(session: session)).response.flatMap( mapListTournaments() )
    }
    
    public func promoteGroupUsers(session: Session, groupId: String, ids: String...) -> EventLoopFuture<Void> {
        var req     = Nakama_Api_PromoteGroupUsersRequest.init()
        req.groupID = groupId
        req.userIds = ids
        return self.nakamaGrpcClient.promoteGroupUsers( req , callOptions: sessionCallOption(session: session)).response.flatMap( mapEmptyVoid() )
    }
    
    public func readStorageObjects(session: Session, objectIds: Nakama_Api_ReadStorageObjectId...) -> EventLoopFuture<Nakama_Api_StorageObjects> {
        var req = Nakama_Api_ReadStorageObjectsRequest.init()
        req.objectIds = objectIds
        return self.nakamaGrpcClient.readStorageObjects( req, callOptions: sessionCallOption(session: session)).response.flatMap( mapStorageObjects() )
    }
    
    public func updateGroup(session: Session, groupId: String, name: String) -> EventLoopFuture<Void> {
        return self.updateGroup(session: session, groupId: groupId, name: name, description: nil, avatarUrl: nil, langTag: nil, open: nil)
    }
    
    public func updateGroup(session: Session, groupId: String?, name: String?, description: String?) -> EventLoopFuture<Void> {
        return self.updateGroup(session: session, groupId: groupId, name: name, description: description, avatarUrl: nil, langTag: nil, open: nil)
    }
    
    public func updateGroup(session: Session, groupId: String?, name: String?, description: String?, avatarUrl: String?) -> EventLoopFuture<Void> {
        return self.updateGroup(session: session, groupId: groupId, name: name, description: description, avatarUrl: avatarUrl, langTag: nil, open: nil)
    }
    
    public func updateGroup(session: Session, groupId: String?, name: String?, description: String?, avatarUrl: String?, langTag: String?) -> EventLoopFuture<Void> {
        return self.updateGroup(session: session, groupId: groupId, name: name, description: description, avatarUrl: avatarUrl, langTag: langTag, open: nil)
    }
    
    public func updateGroup(session: Session, groupId: String?, name: String?, description: String?, avatarUrl: String?, langTag: String?, open: Bool?) -> EventLoopFuture<Void> {
        var req = Nakama_Api_UpdateGroupRequest.init()
        if groupId != nil {
            req.groupID = groupId!
        }
        req.name = Google_Protobuf_StringValue()
        if name != nil {
            req.name.value = name!
        }
        req.description_p = Google_Protobuf_StringValue()
        if description != nil {
            req.description_p.value = description!
        }
        req.avatarURL = Google_Protobuf_StringValue()
        if avatarUrl != nil {
            req.avatarURL.value = avatarUrl!
        }
        req.langTag = Google_Protobuf_StringValue()
        if langTag != nil {
            req.langTag.value = langTag!
        }
        req.open = Google_Protobuf_BoolValue()
        if open != nil {
            req.open.value = open!
        }
        return self.nakamaGrpcClient.updateGroup(req, callOptions: sessionCallOption(session: session) ).response.flatMap( mapEmptyVoid() )
    }
    
    public func writeLeaderboardRecord(session: Session, leaderboardId: String, score: Int64) -> EventLoopFuture<Nakama_Api_LeaderboardRecord> {
        return self.writeLeaderboardRecord(session: session, leaderboardId: leaderboardId, score: score, subscore: nil, metadata: nil)
    }
    
    public func writeLeaderboardRecord(session: Session, leaderboardId: String?, score: Int64?, subscore: Int64?) -> EventLoopFuture<Nakama_Api_LeaderboardRecord> {
        return self.writeLeaderboardRecord(session: session, leaderboardId: leaderboardId, score: score, subscore: subscore, metadata: nil)
    }
    
    public func writeLeaderboardRecord(session: Session, leaderboardId: String?, score: Int64?, metadata: String?) -> EventLoopFuture<Nakama_Api_LeaderboardRecord> {
        return self.writeLeaderboardRecord(session: session, leaderboardId: leaderboardId, score: score, subscore: nil, metadata: metadata)
    }
    
    public func writeLeaderboardRecord(session: Session, leaderboardId: String?, score: Int64?, subscore: Int64?, metadata: String?) -> EventLoopFuture<Nakama_Api_LeaderboardRecord> {
        var req = Nakama_Api_WriteLeaderboardRecordRequest.init()
        if leaderboardId != nil {
            req.leaderboardID = leaderboardId!
        }
        if score != nil {
            req.record.score = score!
        }
        if subscore != nil {
            req.record.subscore = subscore!
        }
        if metadata != nil {
            req.record.metadata = metadata!
        }
        return self.nakamaGrpcClient.writeLeaderboardRecord(req, callOptions: sessionCallOption(session: session)).response.flatMap( mapLeaderBoardRecord() )
    }
    
    /* public func writeStorageObjects(session: Session, objects: Nakama_Api_StorageObjectAck...) -> EventLoopFuture<Nakama_Api_StorageObjectAcks> {
        var req = Nakama_Api_WriteStorageObjectsRequest.init()
        
        return self.nakamaGrpcClient.writeStorageObjects(req, callOptions: sessionCallOption(session: session)).response.flatMap( mapStorageObjects() )
    } */
    
    public func writeTournamentRecord(session: Session, tournamentId: String, score: Int64) -> EventLoopFuture<Nakama_Api_LeaderboardRecord> {
        return self.writeTournamentRecord(session: session, tournamentId: tournamentId, score: score, subscore: nil, metadata: nil)
    }
    
    public func writeTournamentRecord(session: Session, tournamentId: String?, score: Int64?, subscore: Int64?) -> EventLoopFuture<Nakama_Api_LeaderboardRecord> {
        return self.writeTournamentRecord(session: session, tournamentId: tournamentId, score: score, subscore: subscore, metadata: nil)
    }
    
    public func writeTournamentRecord(session: Session, tournamentId: String?, score: Int64?, metadata: String?) -> EventLoopFuture<Nakama_Api_LeaderboardRecord> {
        return self.writeTournamentRecord(session: session, tournamentId: tournamentId, score: score, subscore: nil, metadata: metadata)
    }
    
    public func writeTournamentRecord(session: Session, tournamentId: String?, score: Int64?, subscore: Int64?, metadata: String?) -> EventLoopFuture<Nakama_Api_LeaderboardRecord> {
        var req = Nakama_Api_WriteTournamentRecordRequest.init()
        if tournamentId != nil {
            req.tournamentID = tournamentId!
        }
        if score != nil {
            req.record.score = score!
        }
        if subscore != nil {
            req.record.subscore = subscore!
        }
        if metadata != nil {
            req.record.metadata = metadata!
        }
        return self.nakamaGrpcClient.writeTournamentRecord(req, callOptions: sessionCallOption(session: session)).response.flatMap( mapLeaderBoardRecord() )
    }
 
    public func rpc(session: Session, id: String) -> EventLoopFuture<Nakama_Api_Rpc> {
        return self.rpc(session: session, id: id, payload: nil)
    }
    
    public func rpc(session: Session, id: String, payload: String?) -> EventLoopFuture<Nakama_Api_Rpc> {
        var req = Nakama_Api_Rpc.init()
        req.id = id
        if payload != nil {
            req.payload = payload!
        }
        return self.nakamaGrpcClient.rpcFunc(req, callOptions: sessionCallOption(session: session)).response.flatMap( mapApiRpc() )
    }
    
    public func deleteStorageObjects(session: Session, objectIds: Nakama_Api_DeleteStorageObjectId...) -> EventLoopFuture<Void> {
        var req = Nakama_Api_DeleteStorageObjectsRequest.init()
        req.objectIds = objectIds
        //
        return self.nakamaGrpcClient.deleteStorageObjects(req, callOptions: sessionCallOption(session: session)).response.flatMap( mapEmptyVoid() )
    }
    
    public func listNotifications(session: Session) -> EventLoopFuture<Nakama_Api_NotificationList> {
        return self.listNotifications(session: session, limit: nil, cacheableCursor: nil)
    }
    
    public func listNotifications(session: Session, limit: Int32?) -> EventLoopFuture<Nakama_Api_NotificationList> {
        return self.listNotifications(session: session, limit: limit, cacheableCursor: nil)
    }
    
    public func listNotifications(session: Session, limit: Int32?, cacheableCursor: String?) -> EventLoopFuture<Nakama_Api_NotificationList> {
        var req = Nakama_Api_ListNotificationsRequest.init()
        req.limit = Google_Protobuf_Int32Value()
        if limit != nil {
            req.limit.value = limit!
        }
        if cacheableCursor != nil {
            req.cacheableCursor = cacheableCursor!
        }
        return self.nakamaGrpcClient.listNotifications(req, callOptions: sessionCallOption(session: session) ).response.flatMap( mapApiNotificaionList() )
    }
    
    public func listTournamentRecords(session: Session, tournamentId: String) -> EventLoopFuture<Nakama_Api_TournamentRecordList> {
        return self.listTournamentRecords(session: session, tournamentId: tournamentId, expiry: nil, limit: nil, cursor: nil, ownerIds: nil)
    }
    
    public func listTournamentRecords(session: Session, tournamentId: String?, expiry: Int64?) -> EventLoopFuture<Nakama_Api_TournamentRecordList> {
        return self.listTournamentRecords(session: session, tournamentId: tournamentId, expiry: expiry, limit: nil, cursor: nil, ownerIds: nil)
    }
    
    public func listTournamentRecords(session: Session, tournamentId: String?, expiry: Int64?, limit: Int32?) -> EventLoopFuture<Nakama_Api_TournamentRecordList> {
        return self.listTournamentRecords(session: session, tournamentId: tournamentId, expiry: expiry, limit: limit, cursor: nil, ownerIds: nil)
    }
    
    public func listTournamentRecords(session: Session, tournamentId: String?, expiry: Int64?, limit: Int32?,  cursor: String?) -> EventLoopFuture<Nakama_Api_TournamentRecordList> {
        return self.listTournamentRecords(session: session, tournamentId: tournamentId, expiry: expiry, limit: limit, cursor: cursor, ownerIds: nil)
    }
    
    public func listTournamentRecords(session: Session, tournamentId: String?, ownerIds: [String]?) -> EventLoopFuture<Nakama_Api_TournamentRecordList> {
        return self.listTournamentRecords(session: session, tournamentId: tournamentId, expiry: nil, limit: nil, cursor: nil, ownerIds: ownerIds)
    }
    public func listTournamentRecords(session: Session, tournamentId: String?, expiry: Int64?, limit: Int32?, cursor: String?, ownerIds: [String]?) -> EventLoopFuture<Nakama_Api_TournamentRecordList> {
        var req = Nakama_Api_ListTournamentRecordsRequest.init()
        if tournamentId != nil {
            req.tournamentID = tournamentId!
        }
        req.expiry = Google_Protobuf_Int64Value()
        if expiry != nil {
            req.expiry.value = expiry!
        }
        req.limit = Google_Protobuf_Int32Value()
        if limit != nil {
            req.limit.value = limit!
        }
        if cursor != nil {
            req.cursor = cursor!
        }
        if ownerIds != nil {
            req.ownerIds = ownerIds!
        }
        return self.nakamaGrpcClient.listTournamentRecords(req, callOptions: sessionCallOption(session: session)  ).response.flatMap( mapApiTournamentList() )
    }
    
    public func listUserGroups(session: Session) -> EventLoopFuture<Nakama_Api_UserGroupList> {
        return self.listUserGroups(session: session, userId: nil, state: nil, limit: nil, cursor: nil)
    }
    
    public func listUserGroups(session: Session, userId: String?) -> EventLoopFuture<Nakama_Api_UserGroupList> {
        return self.listUserGroups(session: session, userId: userId, state: nil, limit: nil, cursor: nil)
    }
    
    public func listUserGroups(session: Session, userId: String?, state: Int32?, limit: Int32?, cursor: String?) -> EventLoopFuture<Nakama_Api_UserGroupList> {
        var req = Nakama_Api_ListUserGroupsRequest.init()
        if userId != nil {
            req.userID = userId!
        }
        req.state = Google_Protobuf_Int32Value()
        if state != nil {
            req.state.value = state!
        }
        req.limit = Google_Protobuf_Int32Value()
        if limit != nil {
            req.limit.value = limit!
        }
        if cursor != nil {
            req.cursor = cursor!
        }
        return self.nakamaGrpcClient.listUserGroups(req, callOptions: sessionCallOption(session: session) ).response.flatMap( mapApiUserGroupList() )
    }
}

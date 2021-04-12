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
}

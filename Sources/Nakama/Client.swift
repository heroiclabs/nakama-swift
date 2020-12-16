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
import NIO

/**
 * A client to interact with Nakama server.
 */
public protocol Client {
    var host: String { get }
    var port: Int { get }
    var ssl: Bool { get }
    
    /**
     Disconnects the client. This function kills all outgoing exchanges immediately without waiting.
     */
    func disconnect() -> EventLoopFuture<Void>

    /**
     Create a new socket from the client.
     - Parameter host: The host URL of the server.
     - Parameter port: The port number of the server. Default should be 7350.
     - Parameter ssl: Whether to use SSL to connect to the server.
     - Returns: A new SocketClient instance.
     */
    func createSocket(host: String?, port: Int?, ssl: Bool?) -> SocketClient
    
    /**
     Create a new socket from the client.
     - Parameter host: The host URL of the server.
     - Parameter port: The port number of the server. Default should be 7350.
     - Parameter ssl: Whether to use SSL to connect to the server.
     - Parameter socketAdapter: The socketAdapter to use to create socket. If set to nil, WebSocketAdapter is used.
     - Returns: A new SocketClient instance.
     */
    func createSocket(host: String?, port: Int?, ssl: Bool?, socketAdapter: SocketAdapter?) -> SocketClient

    /**
     Add one or more friends by id or username.
     - Parameter session: The session of the user.
     - Parameter ids: The ids of the users to add or invite as friends.
     - Returns: A future.
     */
    func addFriends(session: Session, ids: String...) -> EventLoopFuture<Void>
    
    /**
     Add one or more friends by id or username.
     - Parameter session: The session of the user.
     - Parameter ids: The ids of the users to add or invite as friends.
     - Parameter usernames: The usernames of the users to add as friends.
     - Returns: A future.
     */
    func addFriends(session: Session, ids: [String]?, usernames: [String]?) -> EventLoopFuture<Void>
    
    /**
     Add one or more users to the group.
     - Parameter session: The session of the user.
     - Parameter groupId: The id of the group to add users into.
     - Parameter id:s: The ids of the users to add or invite to the group.
     - Returns: A future.
     */
    func addGroupUsers(session: Session, groupId: String, ids: String...) -> EventLoopFuture<Void>

    /**
     Authenticate a user with a custom id.
     - Parameter id: A custom identifier usually obtained from an external authentication service.
     - Returns: A future to resolve a session object.
     */
    func authenticateCustom(id: String) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a custom id.
     - Parameter id: A custom identifier usually obtained from an external authentication service.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateCustom(id: String, create: Bool?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a custom id.
     - Parameter id: A custom identifier usually obtained from an external authentication service.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateCustom(id: String, create: Bool?, username: String?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a custom id.
     - Parameter id: A custom identifier usually obtained from an external authentication service.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateCustom(id: String, create: Bool?, username: String?, vars: [String:String]?) -> EventLoopFuture<Session>

    /**
     Authenticate a user with a device id.
     - Parameter id: A device identifier usually obtained from a platform API.
     - Returns: A future to resolve a session object.
     */
    func authenticateDevice(id: String) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a device id.
     - Parameter id: A device identifier usually obtained from a platform API.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateDevice(id: String, create: Bool?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a device id.
     - Parameter id: A device identifier usually obtained from a platform API.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateDevice(id: String, create: Bool?, username: String?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a device id.
     - Parameter id: A device identifier usually obtained from a platform API.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateDevice(id: String, create: Bool?, username: String?, vars: [String:String]?) -> EventLoopFuture<Session>

    /**
     Authenticate a user with an email and password.
     - Parameter email: The email address of the user.
     - Parameter password: The password for the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateEmail(email: String, password: String) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with an email and password.
     - Parameter email: The email address of the user.
     - Parameter password: The password for the user.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateEmail(email: String, password: String, create: Bool?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with an email and password.
     - Parameter email: The email address of the user.
     - Parameter password: The password for the user.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateEmail(email: String, password: String, create: Bool?, username: String?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with an email and password.
     - Parameter email: The email address of the user.
     - Parameter password: The password for the user.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateEmail(email: String, password: String, create: Bool?, username: String?, vars: [String:String]?) -> EventLoopFuture<Session>

    /**
     Authenticate a user with a Facebook auth token.
     - Parameter accessToken: An OAuth access token from the Facebook SDK.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebook(accessToken: String) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a Facebook auth token.
     - Parameter accessToken: An OAuth access token from the Facebook SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebook(accessToken: String, create: Bool?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a Facebook auth token.
     - Parameter accessToken: An OAuth access token from the Facebook SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebook(accessToken: String, create: Bool?, username: String?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a Facebook auth token.
     - Parameter accessToken: An OAuth access token from the Facebook SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter importFriends True if the Facebook friends should be imported.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebook(accessToken: String, create: Bool?, username: String?, importFriends: Bool?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a Facebook auth token.
     - Parameter accessToken: An OAuth access token from the Facebook SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter importFriends True if the Facebook friends should be imported.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebook(accessToken: String, create: Bool?, username: String?, importFriends: Bool?, vars: [String:String]?) -> EventLoopFuture<Session>

    /**
     Authenticate a user with a Google auth token.
     - Parameter accessToken: An OAuth access token from the Google SDK.
     - Returns: A future to resolve a session object.
     */
    func authenticateGoogle(accessToken: String) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a Google auth token.
     - Parameter accessToken: An OAuth access token from the Google SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateGoogle(accessToken: String, create: Bool?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a Google auth token.
     - Parameter accessToken: An OAuth access token from the Google SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateGoogle(accessToken: String, create: Bool?, username: String?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a Google auth token.
     - Parameter accessToken: An OAuth access token from the Google SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateGoogle(accessToken: String, create: Bool?, username: String?, vars: [String:String]?) -> EventLoopFuture<Session>

    /**
     Authenticate a user with a Steam auth token.
     - Parameter token: An authentication token from the Steam network.
     - Returns: A future to resolve a session object.
     */
    func authenticateSteam(token: String) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a Steam auth token.
     - Parameter token: An authentication token from the Steam network.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateSteam(token: String, create: Bool?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a Steam auth token.
     - Parameter token: An authentication token from the Steam network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateSteam(token: String, create: Bool?, username: String?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with a Steam auth token.
     - Parameter token: An authentication token from the Steam network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateSteam(token: String, create: Bool?, username: String?, vars: [String:String]?) -> EventLoopFuture<Session>
    
    
    /**
     Authenticate a user with an Apple auth token.
     - Parameter token: An authentication token from the Apple network.
     - Returns: A future to resolve a session object.
     */
    func authenticateApple(token: String) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with an Apple auth token.
     - Parameter token: An authentication token from the Apple network.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateApple(token: String, create: Bool?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with an Apple auth token.
     - Parameter token: An authentication token from the Apple network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateApple(token: String, create: Bool?, username: String?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with an Apple auth token.
     - Parameter token: An authentication token from the Apple network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateApple(token: String, create: Bool?, username: String?, vars: [String:String]?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with an Facebook Instant Game auth token.
     - Parameter token: An authentication token from the Facebook Instant Game network.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebookInstantGame(signedPlayerInfo: String) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with an Facebook Instant Game auth token.
     - Parameter token: An authentication token from the Facebook Instant Game network.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with an Facebook Instant Game auth token.
     - Parameter token: An authentication token from the Facebook Instant Game network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?, username: String?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with an Facebook Instant Game auth token.
     - Parameter token: An authentication token from the Facebook Instant Game network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?, username: String?, vars: [String:String]?) -> EventLoopFuture<Session>

    /**
     Authenticate a user with Apple Game Center.
     - Parameter playerId: The player id of the user in Game Center.
     - Parameter bundleId: The bundle id of the Game Center application.
     - Parameter timestampSeconds: The date and time that the signature was created.
     - Parameter salt: A random <c>NSString</c> used to compute the hash and keep it randomized.
     - Parameter signature: The verification signature data generated.
     - Parameter publicKeyUrl: The URL for the public encryption key.
     - Returns: A future to resolve a session object.
     */
    func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with Apple Game Center.
     - Parameter playerId: The player id of the user in Game Center.
     - Parameter bundleId: The bundle id of the Game Center application.
     - Parameter timestampSeconds: The date and time that the signature was created.
     - Parameter salt: A random <c>NSString</c> used to compute the hash and keep it randomized.
     - Parameter signature: The verification signature data generated.
     - Parameter publicKeyUrl: The URL for the public encryption key.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with Apple Game Center.
     - Parameter playerId: The player id of the user in Game Center.
     - Parameter bundleId: The bundle id of the Game Center application.
     - Parameter timestampSeconds: The date and time that the signature was created.
     - Parameter salt: A random <c>NSString</c> used to compute the hash and keep it randomized.
     - Parameter signature: The verification signature data generated.
     - Parameter publicKeyUrl: The URL for the public encryption key.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?, username: String?) -> EventLoopFuture<Session>
    
    /**
     Authenticate a user with Apple Game Center.
     - Parameter playerId: The player id of the user in Game Center.
     - Parameter bundleId: The bundle id of the Game Center application.
     - Parameter timestampSeconds: The date and time that the signature was created.
     - Parameter salt: A random <c>NSString</c> used to compute the hash and keep it randomized.
     - Parameter signature: The verification signature data generated.
     - Parameter publicKeyUrl: The URL for the public encryption key.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?, username: String?, vars: [String:String]?) -> EventLoopFuture<Session>
}

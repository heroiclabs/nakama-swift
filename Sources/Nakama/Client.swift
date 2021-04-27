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
    
    /**
     * Bans a user from a group. This will prevent the user from being able to rejoin the group.
     * @param session The session of the user.
     * @param groupId The group to ban the users from.
     * @param ids The users to ban from the group..
     * @return A future.
     */
    func banGroupUsers( session : Session, groupId : String, ids : String... ) -> EventLoopFuture<Void>
    
    /**
     * Block one or more friends by id.
     * @param session The session of the user.
     * @param ids The ids of the users to block.
     * @return A future.
     */
    func blockFriends( session : Session,  ids: String... ) -> EventLoopFuture<Void>


    /**
     * Block one or more friends by id or username.
     * @param session The session of the user.
     * @param ids The ids of the users to block.
     * @param usernames The usernames of the users to block.
     * @return A future.
     */
    func blockFriends(  session : Session, ids : [ String ]?,  usernames:  [ String ]? ) -> EventLoopFuture<Void>
    
    /**
     * Create a group.
     * @param session The session of the user.
     * @param name The name for the group.
     * @return A future to resolve a new group object.
     */
    func createGroup( session: Session, name: String ) -> EventLoopFuture< Nakama_Api_Group >
    
    /**
     * Create a group.
     * @param session The session of the user.
     * @param name The name for the group.
     * @param description A description for the group.
     * @return A future to resolve a new group object.
     */
    func createGroup( session : Session, name: String? ,  description : String?) -> EventLoopFuture<Nakama_Api_Group>

    /**
     * Create a group.
     * @param session The session of the user.
     * @param name The name for the group.
     * @param description A description for the group.
     * @param avatarUrl An avatar url for the group.
     * @return A future to resolve a new group object.
     */
    func createGroup( session: Session, name: String?,  description: String?,  avatarUrl : String? ) -> EventLoopFuture<Nakama_Api_Group>

    /**
     * Create a group.
     * @param session The session of the user.
     * @param name The name for the group.
     * @param description A description for the group.
     * @param avatarUrl An avatar url for the group.
     * @param langTag A language tag in BCP-47 format for the group.
     * @return A future to resolve a new group object.
     */
    func createGroup( session : Session,  name : String?, description : String?, avatarUrl : String?,  langTag : String?) -> EventLoopFuture<Nakama_Api_Group>

    /**
     * Create a group.
     * @param session The session of the user.
     * @param name The name for the group.
     * @param description A description for the group.
     * @param avatarUrl An avatar url for the group.
     * @param langTag A language tag in BCP-47 format for the group.
     * @param open True if the group should have open membership.
     * @return A future to resolve a new group object.
     */
    func createGroup( session : Session,  name : String? , description : String?, avatarUrl : String? ,  langTag : String?, open: Bool?) -> EventLoopFuture<Nakama_Api_Group>

    /**
     * Create a group.
     * @param session The session of the user.
     * @param name The name for the group.
     * @param description A description for the group.
     * @param avatarUrl An avatar url for the group.
     * @param langTag A language tag in BCP-47 format for the group.
     * @param open True if the group should have open membership.
     * @param maxCount Maximum number of group members.
     * @return A future to resolve a new group object.
     */
    func createGroup( session: Session,  name: String?, description : String?, avatarUrl : String?, langTag : String? ,  open: Bool?, maxCount : Int32?) -> EventLoopFuture<Nakama_Api_Group>

    /**
     * Delete one more or users by id.
     * @param session The session of the user.
     * @param ids the user ids to remove as friends.
     * @return A future.
     */
    func deleteFriends( session: Session,  ids : String... ) -> EventLoopFuture<Void>

    /**
     * Delete one more or users by id or username from friends.
     * @param session The session of the user.
     * @param ids the user ids to remove as friends.
     * @param usernames The usernames to remove as friends.
     * @return A future.
     */
    func deleteFriends( session: Session , ids : [String]?,  usernames : [String]? ) -> EventLoopFuture<Void>

    /**
     * Delete a group by id.
     *
     * @param session The session of the user.
     * @param groupId The group id to to remove.
     * @return A future.
     */
    func deleteGroup( session : Session, groupId : String ) -> EventLoopFuture<Void>

    /**
     * Delete a leaderboard record.
     *
     * @param session The session of the user.
     * @param leaderboardId The id of the leaderboard with the record to be deleted.
     * @return A future.
     */
    func deleteLeaderboardRecord( session : Session,  leaderboardId : String ) -> EventLoopFuture<Void>

    /**
     * Delete one or more notifications by id.
     *
     * @param session The session of the user.
     * @param notificationIds The notification ids to remove.
     * @return A future.
     */
    func deleteNotifications( session : Session ,  notificationIds : String...  ) -> EventLoopFuture<Void>

    /**
     * Delete one or more storage objects.
     *
     * @param session The session of the user.
     * @param objectIds The ids of the objects to delete.
     * @return A future.
     */
    func deleteStorageObjects( session : Session,  objectIds: Nakama_Api_DeleteStorageObjectId... ) -> EventLoopFuture<Void>

    /**
     * Demote a set of users in a group to the next role down.
     *
     * @param groupId The group ID to demote in.
     * @param userIds The users to demote.
     * @return A future.
     */
    func demoteGroupUsers( session : Session, groupId : String,  userIds : String... ) -> EventLoopFuture<Void>;

    /**
     * Submit an event for processing in the server's registered runtime custom events handler.
     *
     * @param session The session of the user.
     * @param name An event name, type, category, or identifier.
     * @param properties Arbitrary event property values.
     * @return A future.
     */
    //func emitEvent( session : Session, name : String, properties : [ String: String ]) -> EventLoopFuture<Void>;

    /**
     * Fetch the user account owned by the session.
     *
     * @param session The session of the user.
     * @return A future to resolve an account object.
     */
    //func getAccount( session : Session ) -> EventLoopFuture<Nakama_Api_Account>

    /**
     * Fetch one or more users by id, usernames, and Facebook ids.
     *
     * @param session The session of the user.
     * @param ids List of user IDs.
     * @return A future to resolve user objects.
     */
    func getUsers( session : Session, ids :  String... ) -> EventLoopFuture<Nakama_Api_Users>

    /**
     * Fetch one or more users by id, usernames, and Facebook ids.
     *
     * @param session The session of the user.
     * @param ids List of user IDs.
     * @param usernames List of usernames.
     * @return A future to resolve user objects.
     */
    func getUsers( session : Session, ids : [String]?, usernames : [String]? ) -> EventLoopFuture<Nakama_Api_Users>

    /**
     * Fetch one or more users by id, usernames, and Facebook ids.
     *
     * @param session The session of the user.
     * @param ids List of user IDs.
     * @param usernames List of usernames.
     * @param facebookIds List of Facebook IDs.
     * @return A future to resolve user objects.
     */
    func getUsers( session : Session, ids : [String]?, usernames : [String]?, facebookIds : [String]? ) -> EventLoopFuture<Nakama_Api_Users>

    /**
     * Import Facebook friends and add them to the user's account.
     *
     * The server will import friends when the user authenticates with Facebook. This function can be used to be
     * explicit with the import operation.
     *
     * @param session The session of the user.
     * @param token An OAuth access token from the Facebook SDK.
     * @return A future.
     */
    func importFacebookFriends( session : Session, token : String ) -> EventLoopFuture<Void>
    
    /**
     * Import Facebook friends and add them to the user's account.
     *
     * The server will import friends when the user authenticates with Facebook. This function can be used to be
     * explicit with the import operation.
     *
     * @param session The session of the user.
     * @param token An OAuth access token from the Facebook SDK.
     * @param reset True if the Facebook friend import for the user should be reset.
     * @return A future.
     */
    func importFacebookFriends( session: Session, token: String? , reset : Bool? ) -> EventLoopFuture<Void>

    /**
     * Join a group if it has open membership or request to join it.
     *
     * @param session The session of the user.
     * @param groupId The id of the group to join.
     * @return A future.
     */
    func joinGroup( session : Session,  groupId : String ) -> EventLoopFuture<Void>

    /**
     * Join a group if it has open membership or request to join it.
     *
     * @param session The session of the user.
     * @param tournamentId The id of the tournament to join.
     * @return A future.
     */
    func joinTournament( session : Session, tournamentId : String ) -> EventLoopFuture<Void>

    /**
     * Kick one or more users from the group.
     *
     * @param session The session of the user.
     * @param groupId The id of the group.
     * @param ids The ids of the users to kick.
     * @return A future.
     */
    func kickGroupUsers( session : Session, groupId : String, ids:  String...) -> EventLoopFuture<Void>

    /**
     * Leave a group by id.
     *
     * @param session The session of the user.
     * @param groupId The id of the group to leave.
     * @return A future.
     */
    func leaveGroup( session : Session, groupId : String ) -> EventLoopFuture<Void>
    
    /**
     * Add an Apple ID to the social profiles on the current user's account.
     *
     * @param session The session of the user.
     * @param id The ID token received from Apple to validate.
     * @return A future.
     */
    //func linkApple( session : Session,  token : String ) -> EventLoopFuture<Void>

    /**
     * Link a custom id to the user account owned by the session.
     *
     * @param session The session of the user.
     * @param id A custom identifier usually obtained from an external authentication service.
     * @return A future.
     */
    //func linkCustom( session : Session,  id: String) -> EventLoopFuture<Void>

    /**
     * Link a device id to the user account owned by the session.
     *
     * @param session The session of the user.
     * @param id A device identifier usually obtained from a platform API.
     * @return A future.
     */
    //func linkDevice( session : Session, id : String ) -> EventLoopFuture<Void>

    /**
    * List groups on the server.
    *
    * @param session The session of the user.
    * @param name The name filter to apply to the group list.
    * @return A future to resolve group objects.
    */
    func listGroups( session : Session , name : String ) -> EventLoopFuture<Nakama_Api_GroupList>

   /**
    * List groups on the server.
    *
    * @param session The session of the user.
    * @param name The name filter to apply to the group list.
    * @param limit The number of groups to list.
    * @return A future to resolve group objects.
    */
    func listGroups( session : Session , name : String? , limit: Int32?) -> EventLoopFuture<Nakama_Api_GroupList>

   /**
    * List groups on the server.
    *
    * @param session The session of the user.
    * @param name The name filter to apply to the group list.
    * @param limit The number of groups to list.
    * @param cursor A cursor for the current position in the groups to list.
    * @return A future to resolve group objects.
    */
    func listGroups( session : Session , name : String? , limit: Int32?, cursor : String? ) -> EventLoopFuture<Nakama_Api_GroupList>

    /**
     * List of friends of the current user.
     *
     * @param session The session of the user.
     * @return A future to resolve friend objects.
     */
    func listFriends( session : Session ) -> EventLoopFuture<Nakama_Api_FriendList>

    /**
     * List of friends of the current user.
     *
     * @param session The session of the user.
     * @param state The friend state to list.
     * @param limit Max number of records to return. Between 1 and 100.
     * @param cursor An optional next page cursor.
     * @return A future to resolve friend objects.
     */
    func listFriends( session : Session, state : Int32?, limit : Int32?, cursor : String? ) -> EventLoopFuture<Nakama_Api_FriendList>
    
    /**
     * Fetch a list of matches active on the server.
     *
     * @param session The session of the user.
     * @return A future to resolve match.
     */
    func listMatches( session : Session ) -> EventLoopFuture<Nakama_Api_MatchList>

    /**
     * Fetch a list of matches active on the server.
     *
     * @param session The session of the user.
     * @param min The minimum number of match participants.
     * @return A future to resolve match.
     */
    func listMatches( session : Session, min : Int32? ) -> EventLoopFuture<Nakama_Api_MatchList>

    /**
     * Fetch a list of matches active on the server.
     *
     * @param session The session of the user.
     * @param min The minimum number of match participants.
     * @param max The maximum number of match participants.
     * @return A future to resolve match.
     */
    func listMatches( session : Session, min : Int32?, max : Int32? ) -> EventLoopFuture<Nakama_Api_MatchList>

    /**
     * Fetch a list of matches active on the server.
     *
     * @param session The session of the user.
     * @param min The minimum number of match participants.
     * @param max The maximum number of match participants.
     * @param limit The number of matches to list.
     * @return A future to resolve match.
     */
    func listMatches( session : Session, min : Int32?, max : Int32?, limit : Int32? ) -> EventLoopFuture<Nakama_Api_MatchList>

    /**
     * Fetch a list of matches active on the server.
     *
     * @param session The session of the user.
     * @param min The minimum number of match participants.
     * @param max The maximum number of match participants.
     * @param limit The number of matches to list.
     * @param label The label to filter the match list on.
     * @return A future to resolve match.
     */
    func listMatches( session : Session, min : Int32?, max : Int32?, limit : Int32?, label : String? ) -> EventLoopFuture<Nakama_Api_MatchList>

    /**
     * Fetch a list of matches active on the server.
     *
     * @param session The session of the user.
     * @param min The minimum number of match participants.
     * @param max The maximum number of match participants.
     * @param limit The number of matches to list.
     * @param authoritative <c>True</c> to include authoritative matches.
     * @param label The label to filter the match list on.
     * @return A future to resolve match.
     */
    func listMatches( session : Session, min : Int32?, max : Int32?, limit : Int32?, label : String?, authoritative : Bool? ) -> EventLoopFuture<Nakama_Api_MatchList>

    /**
     * List messages from a chat channel.
     *
     * @param session The session of the user.
     * @param channelId A channel identifier.
     * @return A future to resolve channel message objects.
     */
    func listChannelMessages( session : Session,  channelId : String ) -> EventLoopFuture<Nakama_Api_ChannelMessageList>
    /**
     * List messages from a chat channel.
     *
     * @param session The session of the user.
     * @param channelId A channel identifier.
     * @param limit The number of chat messages to list.
     * @return A future to resolve channel message objects.
     */
    func listChannelMessages( session : Session,  channelId : String?, limit : Int32? ) -> EventLoopFuture<Nakama_Api_ChannelMessageList>

    /**
     * List messages from a chat channel.
     *
     * @param session The session of the user.
     * @param channelId A channel identifier.
     * @param limit The number of chat messages to list.
     * @param cursor A cursor for the current position in the messages history to list.
     * @return A future to resolve channel message objects.
     */
    func listChannelMessages( session : Session,  channelId : String?, limit : Int32?, cursor : String? )  -> EventLoopFuture<Nakama_Api_ChannelMessageList>

    /**
     * List messages from a chat channel.
     *
     * @param session The session of the user.
     * @param channelId A channel identifier.
     * @param limit The number of chat messages to list.
     * @param forward Fetch messages forward from the current cursor (or the start).
     * @param cursor A cursor for the current position in the messages history to list.
     * @return A future to resolve channel message objects.
     */
    func listChannelMessages( session : Session,  channelId : String?, limit : Int32?, cursor : String?, forward : Bool?) -> EventLoopFuture<Nakama_Api_ChannelMessageList>

    /**
     * List records from a leaderboard.
     *
     * @param session The session of the user.
     * @param leaderboardId The id of the leaderboard to list.
     * @return A future to resolve leaderboard record objects.
     */
    func listLeaderboardRecords( session: Session, leaderboardId : String ) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList>

    /**
     * List records from a leaderboard.
     *
     * @param session The session of the user.
     * @param leaderboardId The id of the leaderboard to list.
     * @param ownerIds Record owners to fetch with the list of records.
     * @return A future to resolve leaderboard record objects.
     */
    func listLeaderboardRecords( session : Session, leaderboardId : String?, ownerIds : [String]? ) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList>

    /**
     * List records from a leaderboard.
     *
     * @param session The session of the user.
     * @param leaderboardId The id of the leaderboard to list.
     * @param ownerIds Record owners to fetch with the list of records.
     * @param expiry Expiry in seconds (since epoch) to begin fetching records from.
     * @return A future to resolve leaderboard record objects.
     */
    func listLeaderboardRecords( session : Session, leaderboardId : String?, ownerIds : [String]?, expiry : Int64?) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList>

    /**
     * List records from a leaderboard.
     *
     * @param session The session of the user.
     * @param leaderboardId The id of the leaderboard to list.
     * @param ownerIds Record owners to fetch with the list of records.
     * @param expiry Expiry in seconds (since epoch) to begin fetching records from.
     * @param limit The number of records to list.
     * @return A future to resolve leaderboard record objects.
     */
    func listLeaderboardRecords( session : Session, leaderboardId : String?, ownerIds : [String]?, expiry : Int64? , limit : Int32? ) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList>

    /**
     * List records from a leaderboard.
     *
     * @param session The session of the user.
     * @param leaderboardId The id of the leaderboard to list.
     * @param ownerIds Record owners to fetch with the list of records.
     * @param expiry Expiry in seconds (since epoch) to begin fetching records from.
     * @param limit The number of records to list.
     * @param cursor A cursor for the current position in the leaderboard records to list.
     * @return A future to resolve leaderboard record objects.
     */
    func listLeaderboardRecords(session : Session, leaderboardId : String?, ownerIds : [String]?, expiry : Int64? , limit : Int32? , cursor : String? ) -> EventLoopFuture<Nakama_Api_LeaderboardRecordList>

    /**
    * List storage objects in a collection which have public read access.
    *
    * @param session The session of the user.
    * @param collection The collection to list over.
    * @return A future which resolves to a storage object list.
    */
    func listStorageObjects( session : Session , collection : String ) -> EventLoopFuture<Nakama_Api_StorageObjectList>

   /**
    * List storage objects in a collection which have public read access.
    *
    * @param session The session of the user.
    * @param collection The collection to list over.
    * @param limit The number of objects to list.
    * @return A future which resolves to a storage object list.
    */
    func listStorageObjects( session : Session , collection : String?, limit : Int32?) -> EventLoopFuture<Nakama_Api_StorageObjectList>

   /**
    * List storage objects in a collection which have public read access.
    *
    * @param session The session of the user.
    * @param collection The collection to list over.
    * @param limit The number of objects to list.
    * @param cursor A cursor to paginate over the collection.
    * @return A future which resolves to a storage object list.
    */
    func listStorageObjects( session : Session , collection : String?, limit : Int32?, cursor : String? ) -> EventLoopFuture<Nakama_Api_StorageObjectList>

    
    /**
     * List active/upcoming tournaments based on given filters.
     * @param session The session of the user.
     * @return a future which resolved to a tournament list.
     */
    func listTournaments( session : Session) -> EventLoopFuture<Nakama_Api_TournamentList>

    /**
     * List active/upcoming tournaments based on given filters.
     * @param session The session of the user.
     * @param limit Max number of records to return. Between 1 and 100.
     * @param cursor A next page cursor for listings.
     * @return a future which resolved to a tournament list.
     */
    func listTournaments( session : Session, limit : Int32?, cursor : String? ) -> EventLoopFuture<Nakama_Api_TournamentList>

    /**
     * List active/upcoming tournaments based on given filters.
     * @param session The session of the user.
     * @param categoryStart The start of the categories to include. Defaults to 0.
     * @return a future which resolved to a tournament list.
     */
    func listTournaments( session: Session, categoryStart : UInt32? ) -> EventLoopFuture<Nakama_Api_TournamentList>

    /**
     * List active/upcoming tournaments based on given filters.
     * @param session The session of the user.
     * @param categoryStart The start of the categories to include. Defaults to 0.
     * @param categoryEnd The end of the categories to include. Defaults to 128.
     * @return a future which resolved to a tournament list.
     */
    func listTournaments( session: Session, categoryStart : UInt32?, categoryEnd : UInt32? ) -> EventLoopFuture<Nakama_Api_TournamentList>

    /**
     * List active/upcoming tournaments based on given filters.
     * @param session The session of the user.
     * @param categoryStart The start of the categories to include. Defaults to 0.
     * @param categoryEnd The end of the categories to include. Defaults to 128.
     * @param startTime The start time for tournaments. Defaults to current Unix time.
     * @return a future which resolved to a tournament list.
     */
    func listTournaments( session: Session, categoryStart : UInt32?, categoryEnd : UInt32?, startTime: UInt32?) -> EventLoopFuture<Nakama_Api_TournamentList>

    /**
     * List active/upcoming tournaments based on given filters.
     * @param session The session of the user.
     * @param categoryStart The start of the categories to include. Defaults to 0.
     * @param categoryEnd The end of the categories to include. Defaults to 128.
     * @param startTime The start time for tournaments. Defaults to current Unix time.
     * @param endTime The end time for tournaments. Defaults to +1 year from current Unix time.
     * @return a future which resolved to a tournament list.
     */
    func listTournaments( session: Session, categoryStart : UInt32?, categoryEnd : UInt32?, startTime: UInt32?,  endTime : UInt32? ) -> EventLoopFuture<Nakama_Api_TournamentList>

    /**
     * List active/upcoming tournaments based on given filters.
     * @param session The session of the user.
     * @param categoryStart The start of the categories to include. Defaults to 0.
     * @param categoryEnd The end of the categories to include. Defaults to 128.
     * @param startTime The start time for tournaments. Defaults to current Unix time.
     * @param endTime The end time for tournaments. Defaults to +1 year from current Unix time.
     * @param limit Max number of records to return. Between 1 and 100.
     * @param cursor A next page cursor for listings.
     * @return a future which resolved to a tournament list.
     */
    func listTournaments( session: Session, categoryStart : UInt32?, categoryEnd : UInt32?, startTime: UInt32?,  endTime : UInt32?, cursor :String?) -> EventLoopFuture<Nakama_Api_TournamentList>

    /**
     * Promote one or more users in the group.
     *
     * @param session The session of the user.
     * @param groupId The id of the group to promote users into.
     * @param ids The ids of the users to promote.
     * @return A future.
     */
    func promoteGroupUsers( session : Session, groupId : String , ids : String...) -> EventLoopFuture<Void>
    
    /**
     * Read one or more objects from the storage engine.
     *
     * @param session The session of the user.
     * @param objectIds The objects to read.
     * @return A future to resolve storage objects.
     */
    func readStorageObjects( session : Session, objectIds: Nakama_Api_ReadStorageObjectId... ) -> EventLoopFuture<Nakama_Api_StorageObjects>

    /**
     * Update a group.
     *
     * The user must have the correct access permissions for the group.
     *
     * @param session The session of the user.
     * @param groupId The id of the group to update.
     * @param name A new name for the group.
     * @return A future.
     */
    func updateGroup( session : Session, groupId : String, name : String ) -> EventLoopFuture<Void>

    /**
     * Update a group.
     *
     * The user must have the correct access permissions for the group.
     *
     * @param session The session of the user.
     * @param groupId The id of the group to update.
     * @param name A new name for the group.
     * @param description A new description for the group.
     * @return A future.
     */
    func updateGroup( session : Session, groupId : String?, name : String?, description : String? ) -> EventLoopFuture<Void>

    /**
     * Update a group.
     *
     * The user must have the correct access permissions for the group.
     *
     * @param session The session of the user.
     * @param groupId The id of the group to update.
     * @param name A new name for the group.
     * @param description A new description for the group.
     * @param avatarUrl A new avatar url for the group.
     * @return A future.
     */
    func updateGroup( session : Session, groupId : String?, name : String?, description : String? , avatarUrl : String? ) -> EventLoopFuture<Void>

    /**
     * Update a group.
     *
     * The user must have the correct access permissions for the group.
     *
     * @param session The session of the user.
     * @param groupId The id of the group to update.
     * @param name A new name for the group.
     * @param description A new description for the group.
     * @param avatarUrl A new avatar url for the group.
     * @param langTag A new language tag in BCP-47 format for the group.
     * @return A future.
     */
    func updateGroup( session : Session, groupId : String?, name : String?, description : String? , avatarUrl : String? , langTag : String? ) -> EventLoopFuture<Void>

    /**
     * Update a group.
     *
     * The user must have the correct access permissions for the group.
     *
     * @param session The session of the user.
     * @param groupId The id of the group to update.
     * @param name A new name for the group.
     * @param description A new description for the group.
     * @param avatarUrl A new avatar url for the group.
     * @param langTag A new language tag in BCP-47 format for the group.
     * @param open True if the group should have open membership.
     * @return A future.
     */
    func updateGroup( session : Session, groupId : String?, name : String?, description : String? , avatarUrl : String? , langTag : String? , open : Bool? ) -> EventLoopFuture<Void>
    
    /**
    * Write a record to a leaderboard.
    *
    * @param session The session for the user.
    * @param leaderboardId The id of the leaderboard to write.
    * @param score The score for the leaderboard record.
    * @return A future to complete the leaderboard record write.
    */
    func writeLeaderboardRecord( session : Session,  leaderboardId : String , score : Int64 )  -> EventLoopFuture<Nakama_Api_LeaderboardRecord>

   /**
    * Write a record to a leaderboard.
    *
    * @param session The session for the user.
    * @param leaderboardId The id of the leaderboard to write.
    * @param score The score for the leaderboard record.
    * @param subscore The subscore for the leaderboard record.
    * @return A future to complete the leaderboard record write.
    */
    func writeLeaderboardRecord( session : Session,  leaderboardId : String? , score : Int64? , subscore : Int64? ) -> EventLoopFuture<Nakama_Api_LeaderboardRecord>

   /**
    * Write a record to a leaderboard.
    *
    * @param session The session for the user.
    * @param leaderboardId The id of the leaderboard to write.
    * @param score The score for the leaderboard record.
    * @param metadata The metadata for the leaderboard record.
    * @return A future to complete the leaderboard record write.
    */
    func writeLeaderboardRecord(session : Session,  leaderboardId : String? , score : Int64? ,  metadata : String? ) -> EventLoopFuture<Nakama_Api_LeaderboardRecord>

   /**
    * Write a record to a leaderboard.
    *
    * @param session The session for the user.
    * @param leaderboardId The id of the leaderboard to write.
    * @param score The score for the leaderboard record.
    * @param subscore The subscore for the leaderboard record.
    * @param metadata The metadata for the leaderboard record.
    * @return A future to complete the leaderboard record write.
    */
   func writeLeaderboardRecord( session : Session,  leaderboardId : String? , score : Int64? , subscore : Int64?,  metadata : String? ) -> EventLoopFuture<Nakama_Api_LeaderboardRecord>

    /**
     * Write objects to the storage engine.
     *
     * @param session The session of the user.
     * @param objects The objects to write.
     * @return A future to resolve the acknowledgements with writes.
     */
    //func writeStorageObjects( session: Session, objects:  Nakama_Api_StorageObjectAck... ) -> EventLoopFuture<Nakama_Api_StorageObjectAcks>
    //
    /**
     * A request to submit a score to a tournament.
     *
     * @param session The session for the user.
     * @param tournamentId The tournament ID to write the record for.
     * @param score The score value to submit.
     * @return A future to complete the tournament record write.
     */
    func writeTournamentRecord( session: Session, tournamentId : String , score : Int64 ) -> EventLoopFuture<Nakama_Api_LeaderboardRecord>

    /**
     * A request to submit a score to a tournament.
     *
     * @param session The session for the user.
     * @param tournamentId The tournament ID to write the record for.
     * @param score The score value to submit.
     * @param subscore An optional secondary value.
     * @return A future to complete the tournament record write.
     */
    func writeTournamentRecord(session: Session, tournamentId : String? , score : Int64?, subscore : Int64?) -> EventLoopFuture<Nakama_Api_LeaderboardRecord>

    /**
     * A request to submit a score to a tournament.
     *
     * @param session The session for the user.
     * @param tournamentId The tournament ID to write the record for.
     * @param score The score value to submit.
     * @param metadata A JSON object of additional properties.
     * @return A future to complete the tournament record write.
     */
    func writeTournamentRecord(session: Session, tournamentId : String? , score : Int64?, metadata : String?  ) -> EventLoopFuture<Nakama_Api_LeaderboardRecord>

    /**
     * A request to submit a score to a tournament.
     *
     * @param session The session for the user.
     * @param tournamentId The tournament ID to write the record for.
     * @param score The score value to submit.
     * @param subscore  An optional secondary value.
     * @param metadata A JSON object of additional properties.
     * @return A future to complete the tournament record write.
     */
    func writeTournamentRecord(session: Session, tournamentId : String? , score : Int64?, subscore : Int64?,  metadata : String? ) -> EventLoopFuture<Nakama_Api_LeaderboardRecord>
    
    /**
     * Execute a Lua function with an input payload on the server.
     *
     * @param session The session of the user.
     * @param id The id of the function to execute on the server.
     * @return A future to resolve an RPC response.
     */
    func rpc( session: Session, id: String ) -> EventLoopFuture<Nakama_Api_Rpc>

    /**
     * Execute a Lua function with an input payload on the server.
     *
     * @param session The session of the user.
     * @param id The id of the function to execute on the server.
     * @param payload The payload to send with the function call.
     * @return A future to resolve an RPC response.
     */
    func rpc( session: Session, id: String, payload : String? ) -> EventLoopFuture<Nakama_Api_Rpc>
    
    /**
     * List notifications for the user with an optional cursor.
     *
     * @param session The session of the user.
     * @return A future to resolve notifications objects.
     */
    func listNotifications( session : Session ) -> EventLoopFuture<Nakama_Api_NotificationList>

    /**
     * List notifications for the user with an optional cursor.
     *
     * @param session The session of the user.
     * @param limit The number of notifications to list.
     * @return A future to resolve notifications objects.
     */
    func listNotifications( session : Session, limit : Int32? ) -> EventLoopFuture<Nakama_Api_NotificationList>

    /**
     * List notifications for the user with an optional cursor.
     *
     * @param session The session of the user.
     * @param limit The number of notifications to list.
     * @param cacheableCursor A cursor for the current position in notifications to list.
     * @return A future to resolve notifications objects.
     */
    func listNotifications( session : Session, limit : Int32?, cacheableCursor : String? ) -> EventLoopFuture<Nakama_Api_NotificationList>

    
}

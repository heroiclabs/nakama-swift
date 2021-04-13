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
    //func deleteStorageObjects( session : Session,  StorageObjectId... objectIds);

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

    

}

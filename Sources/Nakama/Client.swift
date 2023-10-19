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

/**
 * A client to interact with Nakama server.
 */
public protocol Client {
    var host: String { get }
    var port: Int { get }
    var ssl: Bool { get }
    var transientErrorAdapter: TransientErrorAdapter? { get }
    var globalRetryConfiguration: RetryConfiguration { get set }
    
    /// True if the session should be refreshed with an active refresh token.
    var autoRefreshSession: Bool { get }
    
    /**
     Disconnects the client. This function kills all outgoing exchanges immediately without waiting.
     */
    func disconnect() async throws -> Void
    
    /**
     Create a new socket from the client.
     - Parameter host: The host URL of the server.
     - Parameter port: The port number of the server. Default should be 7350.
     - Parameter ssl: Whether to use SSL to connect to the server.
     - Parameter socketAdapter: The socketAdapter to use to create socket. If set to nil, WebSocketAdapter is used.
     - Returns: A new SocketClient instance.
     */
    func createSocket(host: String?, port: Int?, ssl: Bool?, socketAdapter: SocketAdapter?) -> SocketProtocol
    
    /**
     Add one or more friends by id or username.
     - Parameter session: The session of the user.
     - Parameter ids: The ids of the users to add or invite as friends.
     - Parameter usernames: The usernames of the users to add as friends.
     - Parameter retryConfig: The retry configuration.
     */
    func addFriends(session: Session, ids: [String], usernames: [String]?, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Authenticate a user with a custom id.
     - Parameter id: A custom identifier usually obtained from an external authentication service.
     - Parameter create: If the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Parameter retryConfig: The retry configuration.
     */
    func authenticateCustom(id: String, create: Bool?, username: String?, vars: [String:String]?, retryConfig: RetryConfiguration?) async throws -> Session
    
    /**
     Authenticate a user with a device id.
     - Parameter id: A device identifier usually obtained from a platform API.
     - Parameter create: If the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Parameter retryConfig: The retry configuration.
     */
    func authenticateDevice(id: String, create: Bool?, username: String?, vars: [String:String]?, retryConfig: RetryConfiguration?) async throws -> Session
    
    /**
     Authenticate a user with an email and password.
     - Parameter email: The email address of the user.
     - Parameter password: The password for the user.
     - Parameter create: If the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Parameter retryConfig: The retry configuration.
     */
    func authenticateEmail(email: String, password: String, create: Bool?, username: String?, vars: [String:String]?, retryConfig: RetryConfiguration?) async throws -> Session
    
    /**
     Authenticate a user with a Facebook auth token.
     - Parameter accessToken: An OAuth access token from the Facebook SDK.
     - Parameter create: If the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter importFriends: If the Facebook friends should be imported.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Parameter retryConfig: The retry configuration.
     */
    func authenticateFacebook(accessToken: String, create: Bool?, username: String?, importFriends: Bool?, vars: [String:String]?, retryConfig: RetryConfiguration?) async throws -> Session
    
    /**
     Authenticate a user with a Google auth token.
     - Parameter accessToken: An OAuth access token from the Google SDK.
     - Parameter create: If the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Parameter retryConfig: The retry configuration.
     */
    func authenticateGoogle(accessToken: String, create: Bool?, username: String?, vars: [String:String]?, retryConfig: RetryConfiguration?) async throws -> Session
    
    /**
     Authenticate a user with a Steam auth token.
     - Parameter token: An authentication token from the Steam network.
     - Parameter create: If the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Parameter retryConfig: The retry configuration.
     */
    func authenticateSteam(token: String, create: Bool?, username: String?, vars: [String:String]?, retryConfig: RetryConfiguration?) async throws -> Session
    
    /**
     Authenticate a user with an Apple auth token.
     - Parameter token: An authentication token from the Apple network.
     - Parameter create: If the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Parameter retryConfig: The retry configuration.
     */
    func authenticateApple(token: String, create: Bool?, username: String?, vars: [String:String]?, retryConfig: RetryConfiguration?) async throws -> Session
    
    /**
     Authenticate a user with an Facebook Instant Game auth token.
     - Parameter token: An authentication token from the Facebook Instant Game network.
     - Parameter create: If the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Parameter retryConfig: The retry configuration.
     */
    func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?, username: String?, vars: [String:String]?, retryConfig: RetryConfiguration?) async throws -> Session
    
    /**
     Authenticate a user with Apple Game Center.
     - Parameter playerId: The player id of the user in Game Center.
     - Parameter bundleId: The bundle id of the Game Center application.
     - Parameter timestampSeconds: The date and time that the signature was created.
     - Parameter salt: A random <c>NSString</c> used to compute the hash and keep it randomized.
     - Parameter signature: The verification signature data generated.
     - Parameter publicKeyUrl: The URL for the public encryption key.
     - Parameter create: If the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Parameter retryConfig: The retry configuration.
     */
    func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?, username: String?, vars: [String:String]?, retryConfig: RetryConfiguration?) async throws -> Session
    
    /**
     Fetch the user account owned by the `session`.
     - Parameter session: Current session.
     - Parameter retryConfig: The retry configuration.
     */
    func getAccount(session: Session, retryConfig: RetryConfiguration?) async throws -> ApiAccount
    
    /**
     Refresh a user session and return the new session.
     - Parameter session: Current session.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Parameter retryConfig: The retry configuration.
     */
    func refreshSession(session: Session, vars: [String:String]?, retryConfig: RetryConfiguration?) async throws -> Session
    
    /**
     Logout user session and invalidate refresh token.
     - Parameter session: Current session.
     - Parameter retryConfig: The retry configuration.
     */
    func sessionLogout(session: Session, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Write objects to the storage engine.
     - Parameter session: Current session.
     - Parameter objects: The objects to write.
     - Parameter retryConfig: The retry configuration.
     */
    func writeStorageObjects(session: Session, objects: [WriteStorageObject], retryConfig: RetryConfiguration?) async throws -> StorageObjectAcks
    
    /**
     Read one or more objects from the storage engine.
     - Parameter session: Current session.
     - Parameter ids: The ids of the objects to read.
     - Parameter retryConfig: The retry configuration.
     */
    func readStorageObjects(session: Session, ids: [StorageObjectId], retryConfig: RetryConfiguration?) async throws -> [StorageObject]
    
    /**
     Delete one or more storage objects.
     - Parameter session: Current session.
     - Parameter ids: The ids of the objects to delete.
     - Parameter retryConfig: The retry configuration.
     */
    func deleteStorageObjects(session: Session, ids: [StorageObjectId], retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     List storage objects in a collection which have public read access.
     - Parameter session: Current session.
     - Parameter collection: The collection to list over.
     - Parameter limit: The number of objects to list. Maximum is 100.
     - Parameter cursor: A cursor to paginate over the collection. Can be nil.
     - Parameter retryConfig: The retry configuration.
     */
    func listStorageObjects(session: Session, collection: String, limit: Int, cursor: String?, retryConfig: RetryConfiguration?) async throws -> StorageObjectList
    
    /**
     Execute an RPC function on the server.
     - Parameter session: Current session.
     - Parameter id: The ID of the function to execute.
     - Parameter payload: The payload to send with the function call.
     - Parameter retryConfig: The retry configuration.
     */
    func rpc(session: Session, id: String, payload: String?, retryConfig: RetryConfiguration?) async throws -> ApiRpc?
    
    /**
     Write a record to a leaderboard.
     - Parameter session: Current session.
     - Parameter leaderboardId: The ID of the leaderboard to write.
     - Parameter score: The score for the leaderboard record.
     - Parameter subScore: The sub score for the leaderboard record.
     - Parameter metadata: The metadata for the leaderboard record.
     - Parameter leaderboardOperator: The operator for the record that can be used to override the one set in the leaderboard.
     - Parameter retryConfig: The retry configuration.
     */
    func writeLeaderboardRecord(session: Session, leaderboardId: String, score: Int, subScore: Int?, metadata: String?, leaderboardOperator: LeaderboardOperator?, retryConfig: RetryConfiguration?) async throws -> LeaderboardRecord
    
    /**
     List records from a leaderboard.
     - Parameter session: Current session.
     - Parameter leaderboardId: The ID of the leaderboard to list.
     - Parameter ownerIds: Record owners to fetch with the list of records. Only owners in this list will be retrieved in `ownerRecords` list.
     - Parameter expiry: Expiry in seconds (since epoch) to begin fetching records from. 0 means from current time.
     - Parameter limit: The number of records to list.
     - Parameter cursor: A cursor for the current position in the leaderboard records to list.
     - Parameter retryConfig: The retry configuration.
     */
    func listLeaderboardRecords(session: Session, leaderboardId: String, ownerIds: [String]?, expiry: Int?, limit: Int, cursor: String?, retryConfig: RetryConfiguration?) async throws -> LeaderboardRecordList
    
    /**
     List leaderboard records that belong to a user.
     - Parameter session: Current session.
     - Parameter leaderboardId: The ID of the leaderboard to list.
     - Parameter ownerId: The ID of the user to list around.
     - Parameter expiry: Expiry in seconds (since epoch) to begin fetching records from. 0 means from current time.
     - Parameter limit: The number of records to list.
     - Parameter retryConfig: The retry configuration.
     */
    func listLeaderboardRecordsAroundOwner(session: Session, leaderboardId: String, ownerId: String, expiry: Int?, limit: Int, cursor: String?, retryConfig: RetryConfiguration?) async throws -> LeaderboardRecordList
    
    /**
     Remove an owner's record from a leaderboard, if one exists.
     - Parameter session: Current session.
     - Parameter leaderboardId: The id of the leaderboard with the record to be deleted.
     - Parameter retryConfig: The retry configuration.
     */
    func deleteLeaderboardRecord(session: Session, leaderboardId: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Join a tournament by ID.
     - Parameter session: Current session.
     - Parameter tournamentId: The ID of the tournament to join.
     - Parameter retryConfig: The retry configuration.
     */
    func joinTournament(session: Session, tournamentId: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     List current or upcoming tournaments.
     - Parameter session: Current session.
     - Parameter categoryStart: The start of the category of tournaments to include.
     - Parameter categoryEnd: The end of the category of tournaments to include.
     - Parameter startTime: The start time of the tournaments. If nil, tournaments will not be filtered by start time.
     - Parameter endTime: The end time of the tournaments. If nil, tournaments will not be filtered by end time.
     - Parameter limit: The number of tournaments to list.
     - Parameter cursor: An optional cursor for the next page of tournaments.
     - Parameter retryConfig: The retry configuration.
     */
    func listTournaments(session: Session, categoryStart: Int, categoryEnd: Int, startTime: Int?, endTime: Int?, limit: Int, cursor: String?, retryConfig: RetryConfiguration?) async throws -> TournamentList
    
    /**
     Write a record to a tournament.
     - Parameter session: Current session.
     - Parameter tournamentId: The ID of the tournament to write.
     - Parameter score: The score of the tournament record.
     - Parameter subScore: The sub score for the tournament record.
     - Parameter metadata: The metadata for the tournament record.
     - Parameter apiOperator: The operator for the record that can be used to override the one set in the tournament.
     - Parameter retryConfig: The retry configuration.
     */
    func writeTournamentRecord(session: Session, tournamentId: String, score: Int, subScore: Int?, metadata: String?, apiOperator: TournamentOperator?, retryConfig: RetryConfiguration?) async throws -> LeaderboardRecord
    
    /**
     List records from a tournament.
     - Parameter session: Current session.
     - Parameter tournamentId: The ID of the tournament.
     - Parameter ownerIds: Record owners to fetch with the list of records. Only owners in this list will be retrieved in `ownerRecords` list.
     - Parameter expiry: Expiry in seconds (since epoch) to begin fetching records from.
     - Parameter limit: The number of records to list.
     - Parameter cursor: An optional cursor for the next page of tournament records.
     - Parameter retryConfig: The retry configuration.
     */
    func listTournamentRecords(session: Session, tournamentId: String, ownerIds: [String]?, expiry: Int?, limit: Int, cursor: String?, retryConfig: RetryConfiguration?) async throws -> TournamentRecordList
    
    /**
     List tournament records around the owner.
     - Parameter session: Current session.
     - Parameter tournamentId: The ID of the tournament.
     - Parameter ownerId: The ID of the owner to pivot around.
     - Parameter expiry: Expiry in seconds (since epoch) to begin fetching records from.
     - Parameter limit: The number of records to list.
     - Parameter cursor: An optional cursor for the next page of tournament records.
     - Parameter retryConfig: The retry configuration.
     */
    func listTournamentRecordsAroundOwner(session: Session, tournamentId: String, ownerId: String, expiry: Int?, limit: Int, cursor: String?, retryConfig: RetryConfiguration?) async throws -> TournamentRecordList
    
    /**
     Create a group.
     - Parameter session: Current session.
     - Parameter name: The name for the group.
     - Parameter description: A description for the group.
     - Parameter avatarUrl: An avatar url for the group.
     - Parameter langTag: A language tag in BCP-47 format for the group.
     - Parameter open: If the group should have open membership. Defaults to false (private).
     - Parameter maxCount: The maximum number of members allowed.
     - Parameter retryConfig: The retry configuration.
     */
    func createGroup(session: Session, name: String, description: String?, avatarUrl: String?, langTag: String?, open: Bool?, maxCount: Int?, retryConfig: RetryConfiguration?) async throws -> Group
    
    /**
     Join a group if it has open membership or request to join it.
     - Parameter session: Current session.
     - Parameter groupId: The ID of the group to join.
     - Parameter retryConfig: The retry configuration.
     */
    func joinGroup(session: Session, groupId: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Leave a group by ID.
     - Parameter session: Current session.
     - Parameter groupId: The ID of the group to leave.
     - Parameter retryConfig: The retry configuration.
     */
    func leaveGroup(session: Session, groupId: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Delete a group by id.
     - Parameter session: Current session.
     - Parameter groupId: The group id to to remove.
     - Parameter retryConfig: The retry configuration.
     */
    func deleteGroup(session: Session, groupId: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     List groups on the server.
     - Parameter session: Current session.
     - Parameter name: The name filter to apply to the group list. The name filter is case insensitive and mutually exclusive to the remainder filters.
     - Parameter limit: The number of groups to list.
     - Parameter cursor: A cursor for the current position in the groups to list.
     - Parameter langTag: The language tag filter to apply to the group list.
     - Parameter members: The number of group members filter to apply to the group list.
     - Parameter open: The open/closed filter to apply to the group list.
     - Parameter retryConfig: The retry configuration.
     */
    func listGroups(session: Session, name: String?, limit: Int, cursor: String?, langTag: String?, members: Int?, open: Bool?, retryConfig: RetryConfiguration?) async throws -> GroupList
    
    /**
     Update a group. The user must have the correct access permissions for the group.
     - Parameter session: Current session.
     - Parameter groupId: The ID of the group to update.
     - Parameter name: A new name for the group.
     - Parameter open: If the group should have open membership.
     - Parameter description: A new description for the group.
     - Parameter avatarUrl: A new avatar url for the group.
     - Parameter langTag: A new language tag in BCP-47 format for the group.
     - Parameter retryConfig: The retry configuration.
     */
    func updateGroup(session: Session, groupId: String, name: String?, open: Bool, description: String?, avatarUrl: String?, langTag: String?, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Add one or more users to the group.
     - Parameter session: The session of the user.
     - Parameter groupId: The id of the group to add users into.
     - Parameter ids: The ids of the users to add or invite to the group.
     - Parameter retryConfig: The retry configuration.
     */
    func addGroupUsers(session: Session, groupId: String, ids: [String], retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Kick one or more users from the group.
     - Parameter session: The session of the user.
     - Parameter groupId: The ID of the group.
     - Parameter ids: The IDs of the users to kick.
     - Parameter retryConfig: The retry configuration.
     */
    func kickGroupUsers(session: Session, groupId: String, ids: [String], retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     List all users part of the group.
     - Parameter session: The session of the user.
     - Parameter groupId: The ID of the group.
     - Parameter state: Filter by group membership state.
     - Parameter limit: The number of groups to list.
     - Parameter cursor: A cursor for the current position in the group listing.
     - Parameter retryConfig: The retry configuration.
     */
    func listGroupUsers(session: Session, groupId: String, state: Int?, limit: Int, cursor: String?, retryConfig: RetryConfiguration?) async throws -> GroupUserList
    
    /**
     List of groups the current user is a member of.
     - Parameter session: The session of the user.
     - Parameter userId: The ID of the user whose groups to list. If `nil` it will be session userId.
     - Parameter state: Filter by group membership state.
     - Parameter limit: The number of records to list.
     - Parameter cursor: A cursor for the current position in the listing.
     - Parameter retryConfig: The retry configuration.
     */
    func listUserGroups(session: Session, userId: String?, state: Int?, limit: Int, cursor: String?, retryConfig: RetryConfiguration?) async throws -> ListUserGroup
    
    /**
     Promote one or more users in a group.
     - Parameter session: The session of the user.
     - Parameter groupId: The ID of the group to promote users into.
     - Parameter ids: The IDs of the users to promote.
     - Parameter retryConfig: The retry configuration.
     */
    func promoteGroupUsers(session: Session, groupId: String, ids: [String], retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Demote a set of users in a group to the next role down.
     - Parameter session: The session of the user.
     - Parameter groupId: The group to demote users in.
     - Parameter ids: The IDs of the users to demote.
     - Parameter retryConfig: The retry configuration.
     */
    func demoteGroupUsers(session: Session, groupId: String, ids: [String], retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Ban a set of users from a group.
     - Parameter session: The session of the user.
     - Parameter groupId: The group to ban the users from.
     - Parameter ids: The IDs of the users to ban.
     - Parameter retryConfig: The retry configuration.
     */
    func banGroupUsers(session: Session, groupId: String, ids: [String], retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Validate a purchase receipt against the Apple App Store.
     - Parameter session: The session of the user.
     - Parameter receipt: The purchase receipt to be validated.
     - Parameter persist: Whether or not to track the receipt in the Nakama database.
     - Parameter retryConfig: The retry configuration.
     */
    func validatePurchaseApple(session: Session, receipt: String, persist: Bool?, retryConfig: RetryConfiguration?) async throws -> ValidatePurchaseResponse
    
    /**
     Validate a purchase receipt against the Google Play Store.
     - Parameter session: The session of the user.
     - Parameter receipt: The purchase receipt to be validated.
     - Parameter persist: Whether or not to track the receipt in the Nakama database.
     - Parameter retryConfig: The retry configuration.
     */
    func validatePurchaseGoogle(session: Session, receipt: String, persist: Bool?, retryConfig: RetryConfiguration?) async throws -> ValidatePurchaseResponse
    
    /**
     Validate a purchase receipt against the Huawei AppGallery.
     - Parameter session: The session of the user.
     - Parameter receipt: The purchase receipt to be validated.
     - Parameter persist: Whether or not to track the receipt in the Nakama database.
     - Parameter retryConfig: The retry configuration.
     */
    func validatePurchaseHuawei(session: Session, receipt: String, persist: Bool?, retryConfig: RetryConfiguration?) async throws -> ValidatePurchaseResponse
    
    /**
     Get the subscription represented by the provided product id.
     - Parameter session: The session of the user.
     - Parameter productId: The product id.
     - Parameter retryConfig: The retry configuration.
     */
    func getSubscription(session: Session, productId: String, retryConfig: RetryConfiguration?) async throws -> ValidatedSubscription
    
    /**
     Validate an Apple subscription receipt.
     - Parameter session: The session of the user.
     - Parameter receipt: The receipt to validate.
     - Parameter persist: Whether or not to persist the receipt to Nakama's database.
     - Parameter retryConfig: The retry configuration.
     */
    func validateSubscriptionApple(session: Session, receipt: String, persist: Bool?, retryConfig: RetryConfiguration?) async throws -> ValidateSubscriptionResponse
    
    /**
     Validate a Google subscription receipt.
     - Parameter session: The session of the user.
     - Parameter receipt: The receipt to validate.
     - Parameter persist: Whether or not to persist the receipt to Nakama's database.
     - Parameter retryConfig: The retry configuration.
     */
    func validateSubscriptionGoogle(session: Session, receipt: String, persist: Bool?, retryConfig: RetryConfiguration?) async throws -> ValidateSubscriptionResponse
    
    /**
     List the user's subscriptions.
     - Parameter session: The session of the user.
     - Parameter limit: The number of subscriptions to list.
     - Parameter cursor: An optional cursor for the next page of subscriptions.
     - Parameter retryConfig: The retry configuration.
     */
    func listSubscriptions(session: Session, limit: Int, cursor: String?, retryConfig: RetryConfiguration?) async throws -> SubscriptionList
    
    /**
     List notifications for the user with an optional cursor.
     - Parameter session: The session of the user.
     - Parameter limit: The number of notifications to list.
     - Parameter cacheableCursor: A cursor for the current position in notifications to list.
     - Parameter retryConfig: The retry configuration.
     */
    func listNotifications(session: Session, limit: Int, cacheableCursor: String?, retryConfig: RetryConfiguration?) async throws -> NotificationList
    
    /**
     Delete one or more notifications by id.
     - Parameter session: The session of the user.
     - Parameter ids: The notification ids to remove.
     - Parameter retryConfig: The retry configuration.
     */
    func deleteNotifications(session: Session, ids: [String], retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Link an Apple ID to the social profiles on the current user's account.
     - Parameter session: The session of the user.
     - Parameter token: The ID token received from Apple to validate.
     */
    func linkApple(session: Session, token: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Link an email with password to the user account owned by the session.
     - Parameter session: The session of the user.
     - Parameter email: The email address of the user.
     - Parameter password: The password for the user.
     - Parameter retryConfig: The retry configuration.
     */
    func linkEmail(session: Session, email: String, password: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Link a Steam profile to a user account.
     - Parameter session: The session of the user.
     - Parameter token: An authentication token from the Steam network.
     - Parameter import: If the Steam friends should be imported.
     - Parameter retryConfig: The retry configuration.
     */
    func linkSteam(session: Session, token: String, import: Bool, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Link a device ID to the user account owned by the session.
     - Parameter session: The session of the user.
     - Parameter id: A device identifier usually obtained from a platform API.
     - Parameter retryConfig: The retry configuration.
     */
    func linkDevice(session: Session, id: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Link a custom ID to the user account owned by the session.
     - Parameter session: The session of the user.
     - Parameter id: A custom identifier usually obtained from an external authentication service.
     - Parameter retryConfig: The retry configuration.
     */
    func linkCustom(session: Session, id: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Link a Google profile to a user account.
     - Parameter session: The session of the user.
     - Parameter token: An OAuth access token from the Google SDK.
     - Parameter retryConfig: The retry configuration.
     */
    func linkGoogle(session: Session, token: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Link a Facebook profile to a user account.
     - Parameter session: The session of the user.
     - Parameter token: An OAuth access token from the Facebook SDK.
     - Parameter import: If the Facebook friends should be imported.
     - Parameter retryConfig: The retry configuration.
     */
    func linkFacebook(session: Session, token: String, import: Bool?, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Link a Game Center profile to a user account.
     - Parameter session: The session of the user.
     - Parameter bundleId: The bundle ID of the Game Center application.
     - Parameter playerId: The player ID of the user in Game Center.
     - Parameter publicKeyUrl: The URL for the public encryption key.
     - Parameter salt: A random `String` used to compute the hash and keep it randomized.
     - Parameter signature: The verification signature data generated.
     - Parameter timestamp: The date and time that the signature was created.
     - Parameter retryConfig: The retry configuration.
     */
    func linkGameCenter(session: Session, bundleId: String, playerId: String, publicKeyUrl: String, salt: String, signature: String, timestamp: Int, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Remove the Apple ID from the social profiles on the current user's account.
     - Parameter session: The session of the user.
     - Parameter token: The ID token received from Apple to validate.
     - Parameter retryConfig: The retry configuration.
     */
    func unlinkApple(session: Session, token: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Unlink an email with password from the user account owned by the session.
     - Parameter session: The session of the user.
     - Parameter email: The email address of the user.
     - Parameter password: The password for the user.
     - Parameter retryConfig: The retry configuration.
     */
    func unlinkEmail(session: Session, email: String, password: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Unlink a Steam profile from the user account owned by the session.
     - Parameter session: The session of the user.
     - Parameter token: An authentication token from the Steam network.
     - Parameter retryConfig: The retry configuration.
     */
    func unlinkSteam(session: Session, token: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Unlink a device ID from the user account owned by the session.
     - Parameter session: The session of the user.
     - Parameter id: A device identifier usually obtained from a platform API.
     - Parameter retryConfig: The retry configuration.
     */
    func unlinkDevice(session: Session, id: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Unlink a custom ID from the user account owned by the session.
     - Parameter session: The session of the user.
     - Parameter id: A custom identifier usually obtained from an external authentication service.
     - Parameter retryConfig: The retry configuration.
     */
    func unlinkCustom(session: Session, id: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Unlink a Google profile from the user account owned by the session.
     - Parameter session: The session of the user.
     - Parameter token: An OAuth access token from the Google SDK.
     - Parameter retryConfig: The retry configuration.
     */
    func unlinkGoogle(session: Session, token: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Unlink a Facebook profile from the user account owned by the session.
     - Parameter session: The session of the user.
     - Parameter token: An OAuth access token from the Facebook SDK.
     - Parameter retryConfig: The retry configuration.
     */
    func unlinkFacebook(session: Session, token: String, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Unlink a Game Center profile from the user account owned by the session.
     - Parameter session: The session of the user.
     - Parameter bundleId: The bundle ID of the Game Center application.
     - Parameter playerId: The player ID of the user in Game Center.
     - Parameter publicKeyUrl: The URL for the public encryption key.
     - Parameter salt: A random `String` used to compute the hash and keep it randomized.
     - Parameter signature: The verification signature data generated.
     - Parameter timestamp: The date and time that the signature was created.
     - Parameter retryConfig: The retry configuration.
     */
    func unlinkGameCenter(session: Session, bundleId: String, playerId: String, publicKeyUrl: String, salt: String, signature: String, timestamp: Int, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Import Facebook friends and add them to the user's account.
     The server will import friends when the user authenticates with Facebook. This function can be used to be explicit with the import operation.
     - Parameter session: The session of the user.
     - Parameter token: An OAuth access token from the Facebook SDK.
     - Parameter reset: If the Facebook friend import for the user should be reset.
     - Parameter retryConfig: The retry configuration.
     */
    func importFacebookFriends(session: Session, token: String, reset: Bool?, retryConfig: RetryConfiguration?) async throws -> Void
    
    /**
     Import Steam friends and add them to the user's account.
     The server will import friends when the user authenticates with Steam. This function can be used to be
     explicit with the import operation.
     - Parameter session: The session of the user.
     - Parameter token: An access token from Steam.
     - Parameter reset: If the Steam friend import for the user should be reset.
     - Parameter retryConfig: The retry configuration.
     */
    func importSteamFriends(session: Session, token: String, reset: Bool?, retryConfig: RetryConfiguration?) async throws -> Void
}

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
    
    /**
     Disconnects the client. This function kills all outgoing exchanges immediately without waiting.
     */
    func disconnect() async throws -> Void

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
    func addFriends(session: Session, ids: String...) async throws -> Void
    
    /**
     Add one or more friends by id or username.
     - Parameter session: The session of the user.
     - Parameter ids: The ids of the users to add or invite as friends.
     - Parameter usernames: The usernames of the users to add as friends.
     - Returns: A future.
     */
    func addFriends(session: Session, ids: [String]?, usernames: [String]?) async throws -> Void
    
    /**
     Add one or more users to the group.
     - Parameter session: The session of the user.
     - Parameter groupId: The id of the group to add users into.
     - Parameter id:s: The ids of the users to add or invite to the group.
     - Returns: A future.
     */
    func addGroupUsers(session: Session, groupId: String, ids: String...) async throws -> Void

    /**
     Authenticate a user with a custom id.
     - Parameter id: A custom identifier usually obtained from an external authentication service.
     - Returns: A future to resolve a session object.
     */
    func authenticateCustom(id: String) async throws -> Session
    
    /**
     Authenticate a user with a custom id.
     - Parameter id: A custom identifier usually obtained from an external authentication service.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateCustom(id: String, create: Bool?) async throws -> Session
    
    /**
     Authenticate a user with a custom id.
     - Parameter id: A custom identifier usually obtained from an external authentication service.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateCustom(id: String, create: Bool?, username: String?) async throws -> Session
    
    /**
     Authenticate a user with a custom id.
     - Parameter id: A custom identifier usually obtained from an external authentication service.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateCustom(id: String, create: Bool?, username: String?, vars: [String:String]?) async throws -> Session

    /**
     Authenticate a user with a device id.
     - Parameter id: A device identifier usually obtained from a platform API.
     - Returns: A future to resolve a session object.
     */
    func authenticateDevice(id: String) async throws -> Session
    
    /**
     Authenticate a user with a device id.
     - Parameter id: A device identifier usually obtained from a platform API.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateDevice(id: String, create: Bool?) async throws -> Session
    
    /**
     Authenticate a user with a device id.
     - Parameter id: A device identifier usually obtained from a platform API.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateDevice(id: String, create: Bool?, username: String?) async throws -> Session
    
    /**
     Authenticate a user with a device id.
     - Parameter id: A device identifier usually obtained from a platform API.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateDevice(id: String, create: Bool?, username: String?, vars: [String:String]?) async throws -> Session

    /**
     Authenticate a user with an email and password.
     - Parameter email: The email address of the user.
     - Parameter password: The password for the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateEmail(email: String, password: String) async throws -> Session
    
    /**
     Authenticate a user with an email and password.
     - Parameter email: The email address of the user.
     - Parameter password: The password for the user.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateEmail(email: String, password: String, create: Bool?) async throws -> Session
    
    /**
     Authenticate a user with an email and password.
     - Parameter email: The email address of the user.
     - Parameter password: The password for the user.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateEmail(email: String, password: String, create: Bool?, username: String?) async throws -> Session
    
    /**
     Authenticate a user with an email and password.
     - Parameter email: The email address of the user.
     - Parameter password: The password for the user.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateEmail(email: String, password: String, create: Bool?, username: String?, vars: [String:String]?) async throws -> Session

    /**
     Authenticate a user with a Facebook auth token.
     - Parameter accessToken: An OAuth access token from the Facebook SDK.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebook(accessToken: String) async throws -> Session
    
    /**
     Authenticate a user with a Facebook auth token.
     - Parameter accessToken: An OAuth access token from the Facebook SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebook(accessToken: String, create: Bool?) async throws -> Session
    
    /**
     Authenticate a user with a Facebook auth token.
     - Parameter accessToken: An OAuth access token from the Facebook SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebook(accessToken: String, create: Bool?, username: String?) async throws -> Session
    
    /**
     Authenticate a user with a Facebook auth token.
     - Parameter accessToken: An OAuth access token from the Facebook SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter importFriends True if the Facebook friends should be imported.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebook(accessToken: String, create: Bool?, username: String?, importFriends: Bool?) async throws -> Session
    
    /**
     Authenticate a user with a Facebook auth token.
     - Parameter accessToken: An OAuth access token from the Facebook SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter importFriends True if the Facebook friends should be imported.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebook(accessToken: String, create: Bool?, username: String?, importFriends: Bool?, vars: [String:String]?) async throws -> Session

    /**
     Authenticate a user with a Google auth token.
     - Parameter accessToken: An OAuth access token from the Google SDK.
     - Returns: A future to resolve a session object.
     */
    func authenticateGoogle(accessToken: String) async throws -> Session
    
    /**
     Authenticate a user with a Google auth token.
     - Parameter accessToken: An OAuth access token from the Google SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateGoogle(accessToken: String, create: Bool?) async throws -> Session
    
    /**
     Authenticate a user with a Google auth token.
     - Parameter accessToken: An OAuth access token from the Google SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateGoogle(accessToken: String, create: Bool?, username: String?) async throws -> Session
    
    /**
     Authenticate a user with a Google auth token.
     - Parameter accessToken: An OAuth access token from the Google SDK.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateGoogle(accessToken: String, create: Bool?, username: String?, vars: [String:String]?) async throws -> Session

    /**
     Authenticate a user with a Steam auth token.
     - Parameter token: An authentication token from the Steam network.
     - Returns: A future to resolve a session object.
     */
    func authenticateSteam(token: String) async throws -> Session
    
    /**
     Authenticate a user with a Steam auth token.
     - Parameter token: An authentication token from the Steam network.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateSteam(token: String, create: Bool?) async throws -> Session
    
    /**
     Authenticate a user with a Steam auth token.
     - Parameter token: An authentication token from the Steam network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateSteam(token: String, create: Bool?, username: String?) async throws -> Session
    
    /**
     Authenticate a user with a Steam auth token.
     - Parameter token: An authentication token from the Steam network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateSteam(token: String, create: Bool?, username: String?, vars: [String:String]?) async throws -> Session
    
    
    /**
     Authenticate a user with an Apple auth token.
     - Parameter token: An authentication token from the Apple network.
     - Returns: A future to resolve a session object.
     */
    func authenticateApple(token: String) async throws -> Session
    
    /**
     Authenticate a user with an Apple auth token.
     - Parameter token: An authentication token from the Apple network.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateApple(token: String, create: Bool?) async throws -> Session
    
    /**
     Authenticate a user with an Apple auth token.
     - Parameter token: An authentication token from the Apple network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateApple(token: String, create: Bool?, username: String?) async throws -> Session
    
    /**
     Authenticate a user with an Apple auth token.
     - Parameter token: An authentication token from the Apple network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateApple(token: String, create: Bool?, username: String?, vars: [String:String]?) async throws -> Session
    
    /**
     Authenticate a user with an Facebook Instant Game auth token.
     - Parameter token: An authentication token from the Facebook Instant Game network.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebookInstantGame(signedPlayerInfo: String) async throws -> Session
    
    /**
     Authenticate a user with an Facebook Instant Game auth token.
     - Parameter token: An authentication token from the Facebook Instant Game network.
     - Parameter create: True if the user should be created when authenticated.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?) async throws -> Session
    
    /**
     Authenticate a user with an Facebook Instant Game auth token.
     - Parameter token: An authentication token from the Facebook Instant Game network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?, username: String?) async throws -> Session
    
    /**
     Authenticate a user with an Facebook Instant Game auth token.
     - Parameter token: An authentication token from the Facebook Instant Game network.
     - Parameter create: True if the user should be created when authenticated.
     - Parameter username: A username used to create the user.
     - Parameter vars: Extra information that will be bundled in the session token.
     - Returns: A future to resolve a session object.
     */
    func authenticateFacebookInstantGame(signedPlayerInfo: String, create: Bool?, username: String?, vars: [String:String]?) async throws -> Session

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
    func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String) async throws -> Session
    
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
    func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?) async throws -> Session
    
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
    func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?, username: String?) async throws -> Session
    
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
    func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int64, salt: String, signature: String, publicKeyUrl: String, create: Bool?, username: String?, vars: [String:String]?) async throws -> Session
    /**
     Refresh a user session and return the new session.
     - Parameter session: Current session.
     - Parameter vars: Extra information that will be bundled in the session token.
    */
    func refreshSession(session: Session, vars: [String:String]) async throws -> Session
    
    /**
     Logout user session and invalidate refresh token.
     - Parameter session: Current session.
     */
    func sessionLogout(session: Session) async throws -> Void
    
    /**
     Write objects to the storage engine.
     - Parameter session: Current session.
     - Parameter objects: The objects to write.
     */
    func writeStorageObjects(session: Session, objects: [WriteStorageObject]) async throws -> StorageObjectAcks
    
    /**
     Read one or more objects from the storage engine.
     - Parameter session: Current session.
     - Parameter ids: The ids of the objects to read.
     */
    func readStorageObjects(session: Session, ids: [StorageObjectId]) async throws -> [StorageObject]
    
    /**
     Delete one or more storage objects.
     - Parameter session: Current session.
     - Parameter ids: The ids of the objects to delete.
     */
    func deleteStorageObjects(session: Session, ids: [StorageObjectId]) async throws -> Void
    
    /**
     List storage objects in a collection which have public read access.
     - Parameter session: Current session.
     - Parameter collection: The collection to list over.
     */
    func listStorageObjects(session: Session, collection: String) async throws -> StorageObjectList
    
    /**
     List storage objects in a collection which have public read access.
     - Parameter session: Current session.
     - Parameter collection: The collection to list over.
     - Parameter limit: The number of objects to list. Maximum is 100.
     - Parameter cursor: A cursor to paginate over the collection. Can be nil.
     */
    func listStorageObjects(session: Session, collection: String, limit: Int, cursor: String?) async throws -> StorageObjectList
    
    /**
     Execute an RPC function on the server.
     - Parameter session: Current session.
     - Parameter id: The ID of the function to execute on the server.
     - Returns: The RPC response.
     */
    func rpc(session: Session, id: String) async throws -> ApiRpc?
    
    /**
     Execute an RPC function on the server.
     - Parameter session: Current session.
     - Parameter id: The ID of the function to execute.
     - Parameter payload: The payload to send with the function call.
     - Returns: The RPC response.
     */
    func rpc(session: Session, id: String, payload: String?) async throws -> ApiRpc?
    
    /**
     Write a record to a leaderboard.
     - Parameter session: Current session.
     - Parameter leaderboardId: The ID of the leaderboard to write.
     - Parameter score: The score for the leaderboard record.
     - Parameter subScore: The sub score for the leaderboard record.
     - Parameter metadata: The metadata for the leaderboard record.
     - Parameter operator: The operator for the record that can be used to override the one set in the leaderboard.
     */
    func writeLeaderboardRecord(session: Session, leaderboardId: String, score: Int, subScore: Int, metadata: String, leaderboardOperator: LeaderboardOperator) async throws -> LeaderboardRecord
    
    /**
     List records from a leaderboard.
     - Parameter session: Current session.
     - Parameter leaderboardId: The ID of the leaderboard to list.
     - Parameter ownerIds: Record owners to fetch with the list of records. Only owners in this list will be retrieved in `records` list.
     */
    func listLeaderboardRecords(session: Session, leaderboardId: String, ownerIds: [String]) async throws -> LeaderboardRecordList
    
    /**
     List records from a leaderboard.
     - Parameter session: Current session.
     - Parameter leaderboardId: The ID of the leaderboard to list.
     - Parameter ownerIds: Record owners to fetch with the list of records. Only owners in this list will be retrieved in `ownerRecords` list.
     - Parameter expiry: Expiry in seconds (since epoch) to begin fetching records from. 0 means from current time.
     - Parameter limit: The number of records to list.
     - Parameter cursor: A cursor for the current position in the leaderboard records to list.
     */
    func listLeaderboardRecords(session: Session, leaderboardId: String, ownerIds: [String], expiry: Int?, limit: Int, cursor: String?) async throws -> LeaderboardRecordList
    
    /**
     List leaderboard records that belong to a user. Owner records will be returned in `records` field of `LeaderboardRecordList`.
     - Parameter session: Current session.
     - Parameter leaderboardId: The ID of the leaderboard to list.
     - Parameter ownerId: The ID of the user to list around.
     */
    func listLeaderboardRecordsAroundOwner(session: Session, leaderboardId: String, ownerId: String) async throws -> LeaderboardRecordList
    
    /**
     List leaderboard records that belong to a user.
     - Parameter session: Current session.
     - Parameter leaderboardId: The ID of the leaderboard to list.
     - Parameter ownerId: The ID of the user to list around.
     - Parameter expiry: Expiry in seconds (since epoch) to begin fetching records from. 0 means from current time.
     - Parameter limit: The number of records to list.
     */
    func listLeaderboardRecordsAroundOwner(session: Session, leaderboardId: String, ownerId: String, expiry: Int?, limit: Int, cursor: String?) async throws -> LeaderboardRecordList
    
    /**
     Remove an owner's record from a leaderboard, if one exists.
     - Parameter session: Current session.
     - Parameter leaderboardId: The id of the leaderboard with the record to be deleted.
     */
    func deleteLeaderboardRecord(session: Session, leaderboardId: String) async throws -> Void
    
    /**
     Join a tournament by ID.
     - Parameter session: Current session.
     - Parameter tournamentId: The ID of the tournament to join.
     */
    func joinTournament(session: Session, tournamentId: String) async throws -> Void
    
    /**
     List current or upcoming tournaments.
     - Parameter session: Current session.
     - Parameter categoryStart: The start of the category of tournaments to include.
     - Parameter categoryEnd: The end of the category of tournaments to include.
     - Parameter startTime: The start time of the tournaments. If nil, tournaments will not be filtered by start time.
     - Parameter endTime: The end time of the tournaments. If nil, tournaments will not be filtered by end time.
     - Parameter limit: The number of tournaments to list.
     - Parameter cursor: An optional cursor for the next page of tournaments.
     */
    func listTournaments(session: Session, categoryStart: Int, categoryEnd: Int, startTime: Int?, endTime: Int?, limit: Int, cursor: String?) async throws -> TournamentList
    
    /**
     Write a record to a tournament.
     - Parameter session: Current session.
     - Parameter tournamentId: The ID of the tournament to write.
     - Parameter score: The score of the tournament record.
     - Parameter subScore: The sub score for the tournament record.
     - Parameter metadata: The metadata for the tournament record.
     - Parameter apiOperator: The operator for the record that can be used to override the one set in the tournament.
     */
    func writeTournamentRecord(session: Session, tournamentId: String, score: Int, subScore: Int, metadata: String, apiOperator: TournamentOperator) async throws -> LeaderboardRecord
    
    /**
     List records from a tournament.
     - Parameter session: Current session.
     - Parameter tournamentId: The ID of the tournament.
     - Parameter ownerIds: Record owners to fetch with the list of records. Only owners in this list will be retrieved in `ownerRecords` list.
     - Parameter expiry: Expiry in seconds (since epoch) to begin fetching records from.
     - Parameter limit: The number of records to list.
     - Parameter cursor: An optional cursor for the next page of tournament records.
     */
    func listTournamentRecords(session: Session, tournamentId: String, ownerIds: [String], expiry: Int?, limit: Int, cursor: String?) async throws -> TournamentRecordList
    
    /**
     List tournament records around the owner.
     - Parameter session: Current session.
     - Parameter tournamentId: The ID of the tournament.
     - Parameter ownerId: The ID of the owner to pivot around.
     - Parameter expiry: Expiry in seconds (since epoch) to begin fetching records from.
     - Parameter limit: The number of records to list.
     - Parameter cursor: An optional cursor for the next page of tournament records.
     */
    func listTournamentRecordsAroundOwner(session: Session, tournamentId: String, ownerId: String, expiry: Int?, limit: Int, cursor: String?) async throws -> TournamentRecordList
    
}

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

public protocol NakamaClientProtocol {
    var globalRetryConfiguration: RetryConfiguration { get set }

    // MARK: Session

    func authenticateApple(token: String, username: String, create: Bool?, vars: [String: String], retryConfig: RetryConfiguration?) async throws -> Session
    func authenticateCustom(id: String, username: String, create: Bool?, vars: [String: String], retryConfig: RetryConfiguration?) async throws -> Session
    func authenticateDevice(id: String, username: String, create: Bool?, vars: [String: String], retryConfig: RetryConfiguration?) async throws -> Session
    func authenticateEmail(email: String, password: String, username: String, create: Bool?, vars: [String: String], retryConfig: RetryConfiguration?) async throws -> Session
    func authenticateFacebook(token: String, username: String, create: Bool?, sync: Bool?, vars: [String: String], retryConfig: RetryConfiguration?) async throws -> Session
    func authenticateFacebookInstantGame(signedPlayerInfo: String, username: String, create: Bool?, vars: [String: String], retryConfig: RetryConfiguration?) async throws -> Session
    func authenticateGameCenter(playerId: String, bundleId: String, timestampSeconds: Int, salt: String, signature: String, publicKeyUrl: String, username: String, create: Bool?, vars: [String: String], retryConfig: RetryConfiguration?) async throws -> Session
    func authenticateGoogle(token: String, username: String, create: Bool?, vars: [String: String], retryConfig: RetryConfiguration?) async throws -> Session
    func authenticateSteam(token: String, username: String, create: Bool?, sync: Bool?, vars: [String: String], retryConfig: RetryConfiguration?) async throws -> Session

    /// Renew `session`'s tokens. The session is updated in place and also returned.
    func sessionRefresh(session: Session, vars: [String: String], retryConfig: RetryConfiguration?) async throws -> Session
    func sessionLogout(session: Session, retryConfig: RetryConfiguration?) async throws
    func healthcheck(retryConfig: RetryConfiguration?) async throws

    // MARK: Account and users

    func getAccount(session: Session, retryConfig: RetryConfiguration?) async throws -> NakamaAccount
    func updateAccount(session: Session, username: String?, displayName: String?, avatarUrl: String?, langTag: String?, location: String?, timezone: String?, retryConfig: RetryConfiguration?) async throws
    func deleteAccount(session: Session, retryConfig: RetryConfiguration?) async throws
    func getUsers(session: Session, ids: [String], usernames: [String], facebookIds: [String], retryConfig: RetryConfiguration?) async throws -> NakamaUsers

    // MARK: Friends

    func addFriends(session: Session, ids: [String], usernames: [String], retryConfig: RetryConfiguration?) async throws
    func deleteFriends(session: Session, ids: [String], usernames: [String], retryConfig: RetryConfiguration?) async throws
    func blockFriends(session: Session, ids: [String], usernames: [String], retryConfig: RetryConfiguration?) async throws
    func listFriends(session: Session, state: Int?, limit: Int?, cursor: String, retryConfig: RetryConfiguration?) async throws -> NakamaFriendList
    func importFacebookFriends(session: Session, token: String, reset: Bool?, retryConfig: RetryConfiguration?) async throws
    func importSteamFriends(session: Session, token: String, reset: Bool?, retryConfig: RetryConfiguration?) async throws

    // MARK: Storage

    func readStorageObjects(session: Session, objectIds: [NakamaReadStorageObjectId], retryConfig: RetryConfiguration?) async throws -> NakamaStorageObjects
    func writeStorageObjects(session: Session, objects: [NakamaWriteStorageObject], retryConfig: RetryConfiguration?) async throws -> NakamaStorageObjectAcks
    func deleteStorageObjects(session: Session, objectIds: [NakamaDeleteStorageObjectId], retryConfig: RetryConfiguration?) async throws
    func listStorageObjects(session: Session, collection: String, userId: String, limit: Int?, cursor: String, retryConfig: RetryConfiguration?) async throws -> NakamaStorageObjectList

    // MARK: Link and unlink

    func linkApple(session: Session, token: String, retryConfig: RetryConfiguration?) async throws
    func linkCustom(session: Session, id: String, retryConfig: RetryConfiguration?) async throws
    func linkDevice(session: Session, id: String, retryConfig: RetryConfiguration?) async throws
    func linkEmail(session: Session, email: String, password: String, retryConfig: RetryConfiguration?) async throws
    func linkFacebook(session: Session, token: String, sync: Bool?, retryConfig: RetryConfiguration?) async throws
    func linkFacebookInstantGame(session: Session, signedPlayerInfo: String, retryConfig: RetryConfiguration?) async throws
    func linkGameCenter(session: Session, playerId: String, bundleId: String, timestampSeconds: Int, salt: String, signature: String, publicKeyUrl: String, retryConfig: RetryConfiguration?) async throws
    func linkGoogle(session: Session, token: String, retryConfig: RetryConfiguration?) async throws
    func linkSteam(session: Session, token: String, sync: Bool?, retryConfig: RetryConfiguration?) async throws

    func unlinkApple(session: Session, token: String, retryConfig: RetryConfiguration?) async throws
    func unlinkCustom(session: Session, id: String, retryConfig: RetryConfiguration?) async throws
    func unlinkDevice(session: Session, id: String, retryConfig: RetryConfiguration?) async throws
    func unlinkEmail(session: Session, email: String, password: String, retryConfig: RetryConfiguration?) async throws
    func unlinkFacebook(session: Session, token: String, retryConfig: RetryConfiguration?) async throws
    func unlinkFacebookInstantGame(session: Session, signedPlayerInfo: String, retryConfig: RetryConfiguration?) async throws
    func unlinkGameCenter(session: Session, playerId: String, bundleId: String, timestampSeconds: Int, salt: String, signature: String, publicKeyUrl: String, retryConfig: RetryConfiguration?) async throws
    func unlinkGoogle(session: Session, token: String, retryConfig: RetryConfiguration?) async throws
    func unlinkSteam(session: Session, token: String, retryConfig: RetryConfiguration?) async throws

    // MARK: Groups

    func createGroup(session: Session, name: String, description: String, langTag: String, avatarUrl: String, open: Bool, maxCount: Int, retryConfig: RetryConfiguration?) async throws -> NakamaGroup
    func updateGroup(session: Session, groupId: String, name: String?, description: String?, langTag: String?, avatarUrl: String?, open: Bool?, retryConfig: RetryConfiguration?) async throws
    func deleteGroup(session: Session, groupId: String, retryConfig: RetryConfiguration?) async throws
    func listGroups(session: Session, name: String, cursor: String, limit: Int?, langTag: String, members: Int?, open: Bool?, retryConfig: RetryConfiguration?) async throws -> NakamaGroupList
    func listGroupUsers(session: Session, groupId: String, limit: Int?, state: Int?, cursor: String, retryConfig: RetryConfiguration?) async throws -> NakamaGroupUserList
    func listUserGroups(session: Session, userId: String, limit: Int?, state: Int?, cursor: String, retryConfig: RetryConfiguration?) async throws -> NakamaUserGroupList
    func joinGroup(session: Session, groupId: String, retryConfig: RetryConfiguration?) async throws
    func leaveGroup(session: Session, groupId: String, retryConfig: RetryConfiguration?) async throws
    func addGroupUsers(session: Session, groupId: String, userIds: [String], retryConfig: RetryConfiguration?) async throws
    func banGroupUsers(session: Session, groupId: String, userIds: [String], retryConfig: RetryConfiguration?) async throws
    func kickGroupUsers(session: Session, groupId: String, userIds: [String], retryConfig: RetryConfiguration?) async throws
    func promoteGroupUsers(session: Session, groupId: String, userIds: [String], retryConfig: RetryConfiguration?) async throws
    func demoteGroupUsers(session: Session, groupId: String, userIds: [String], retryConfig: RetryConfiguration?) async throws

    // MARK: Leaderboards

    func writeLeaderboardRecord(session: Session, leaderboardId: String, score: Int, subscore: Int, metadata: String, operator: NakamaOperator, retryConfig: RetryConfiguration?) async throws -> NakamaLeaderboardRecord
    func deleteLeaderboardRecord(session: Session, leaderboardId: String, retryConfig: RetryConfiguration?) async throws
    func listLeaderboardRecords(session: Session, leaderboardId: String, ownerIds: [String], limit: Int?, cursor: String, expiry: Int?, retryConfig: RetryConfiguration?) async throws -> NakamaLeaderboardRecordList
    func listLeaderboardRecordsAroundOwner(session: Session, leaderboardId: String, ownerId: String, limit: Int?, expiry: Int?, cursor: String, retryConfig: RetryConfiguration?) async throws -> NakamaLeaderboardRecordList

    // MARK: Tournaments

    func listTournaments(session: Session, categoryStart: Int?, categoryEnd: Int?, startTime: Int?, endTime: Int?, limit: Int?, cursor: String, retryConfig: RetryConfiguration?) async throws -> NakamaTournamentList
    func joinTournament(session: Session, tournamentId: String, retryConfig: RetryConfiguration?) async throws
    func writeTournamentRecord(session: Session, tournamentId: String, score: Int, subscore: Int, metadata: String, operator: NakamaOperator, retryConfig: RetryConfiguration?) async throws -> NakamaLeaderboardRecord
    func deleteTournamentRecord(session: Session, tournamentId: String, retryConfig: RetryConfiguration?) async throws
    func listTournamentRecords(session: Session, tournamentId: String, ownerIds: [String], limit: Int?, cursor: String, expiry: Int?, retryConfig: RetryConfiguration?) async throws -> NakamaTournamentRecordList
    func listTournamentRecordsAroundOwner(session: Session, tournamentId: String, ownerId: String, limit: Int?, expiry: Int?, cursor: String, retryConfig: RetryConfiguration?) async throws -> NakamaTournamentRecordList

    // MARK: Chat, notifications, matches

    func listChannelMessages(session: Session, channelId: String, limit: Int?, forward: Bool?, cursor: String, retryConfig: RetryConfiguration?) async throws -> NakamaChannelMessageList
    func listNotifications(session: Session, limit: Int?, cacheableCursor: String, retryConfig: RetryConfiguration?) async throws -> NakamaNotificationList
    func deleteNotifications(session: Session, ids: [String], retryConfig: RetryConfiguration?) async throws
    func listMatches(session: Session, limit: Int?, authoritative: Bool?, label: String?, minSize: Int?, maxSize: Int?, query: String?, retryConfig: RetryConfiguration?) async throws -> NakamaMatchList

    // MARK: Purchases and subscriptions

    func validatePurchaseApple(session: Session, receipt: String, persist: Bool?, retryConfig: RetryConfiguration?) async throws -> NakamaValidatePurchaseResponse
    func validatePurchaseGoogle(session: Session, purchase: String, persist: Bool?, retryConfig: RetryConfiguration?) async throws -> NakamaValidatePurchaseResponse
    func validatePurchaseHuawei(session: Session, purchase: String, signature: String, persist: Bool?, retryConfig: RetryConfiguration?) async throws -> NakamaValidatePurchaseResponse
    func validateSubscriptionApple(session: Session, receipt: String, persist: Bool?, retryConfig: RetryConfiguration?) async throws -> NakamaValidateSubscriptionResponse
    func validateSubscriptionGoogle(session: Session, receipt: String, persist: Bool?, retryConfig: RetryConfiguration?) async throws -> NakamaValidateSubscriptionResponse
    func getSubscription(session: Session, productId: String, retryConfig: RetryConfiguration?) async throws -> NakamaValidatedSubscription
    func listSubscriptions(session: Session, limit: Int?, cursor: String, retryConfig: RetryConfiguration?) async throws -> NakamaSubscriptionList

    // MARK: Rpc and events

    func rpc(session: Session, id: String, payload: String, retryConfig: RetryConfiguration?) async throws -> NakamaRpc
    func event(session: Session, name: String, timestamp: Date, external: Bool, properties: [String: String], retryConfig: RetryConfiguration?) async throws
}

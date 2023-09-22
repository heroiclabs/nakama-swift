/*
 * Copyright © 2023 Heroic Labs
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

extension Nakama_Api_Session {
    func toSession() async -> Session {
        return DefaultSession(token: self.token, refreshToken: self.refreshToken, created: self.created)
    }
}

extension Nakama_Api_StorageObject {
    func toStorageObject() -> StorageObject {
        return StorageObject(
            collection: self.collection,
            userID: self.userID,
            key: self.key,
            value: self.value,
            version: self.version,
            permissionRead: StorageReadPermission(rawValue: Int(self.permissionRead))!,
            permissionWrite: StorageWritePermission(rawValue: Int(self.permissionWrite))!
        )
    }
}

extension Nakama_Api_StorageObjectList {
    func toStorageObjectList() -> StorageObjectList {
        return StorageObjectList(
            cursor: self.cursor,
            objects: self.objects.map { $0.toStorageObject() }
        )
    }
}

extension Nakama_Api_StorageObjectAck {
    func toStorageObjectAck() -> StorageObjectAck {
        return StorageObjectAck(
            collection: self.collection,
            key: self.key,
            userId: self.userID,
            version: self.version
        )
    }
}

extension Nakama_Api_StorageObjectAcks {
    func toStorageObjectAcks() -> StorageObjectAcks {
        return StorageObjectAcks(acks: self.acks.map { $0.toStorageObjectAck() })
    }
}

extension Nakama_Api_Rpc {
    func toApiRpc() -> ApiRpc {
        return ApiRpc(
            id: self.id,
            payload: self.payload,
            httpKey: self.httpKey
        )
    }
}

extension Nakama_Api_LeaderboardRecord {
    func toLeaderboardRecord() -> LeaderboardRecord {
        return LeaderboardRecord(
            createTime: self.createTime.date,
            expiryTime: self.expiryTime.date,
            updateTime: self.updateTime.date,
            leaderboardId: self.leaderboardID,
            username: self.username.value,
            ownerId: self.ownerID,
            score: Int(self.score),
            subScore: Int(self.subscore),
            metadata: self.metadata,
            numScore: Int(self.numScore),
            maxNumScore: Int(self.maxNumScore)
        )
    }
}

extension Nakama_Api_LeaderboardRecordList {
    func toLeaderboardRecordList() -> LeaderboardRecordList {
        return LeaderboardRecordList(
            nextCursor: self.nextCursor,
            prevCursor: self.prevCursor,
            ownerRecords: self.ownerRecords.map { $0.toLeaderboardRecord() },
            records: self.records.map { $0.toLeaderboardRecord() }
        )
    }
}

extension Nakama_Api_Tournament {
    func toTournament() -> Tournament {
        return Tournament(
            id: self.id,
            title: self.title,
            description: self.description_p,
            category: Int(self.category),
            sortOrder: Int(self.sortOrder),
            size: Int(self.size),
            maxSize: Int(self.maxSize),
            maxNumScore: Int(self.maxNumScore),
            canEnter: self.canEnter,
            endActive: Int(self.endActive),
            nextReset: Int(self.nextReset),
            metadata: self.metadata
        )
    }
}

extension Nakama_Api_TournamentList {
    func toTournamentList() -> TournamentList {
        return TournamentList(
            tournaments: self.tournaments.map { $0.toTournament() },
            cursor: self.cursor
        )
    }
}

extension Nakama_Api_TournamentRecordList {
    func toTournamentRecordList() -> TournamentRecordList {
        return TournamentRecordList(
            nextCursor: self.nextCursor,
            prevCursor: self.prevCursor,
            ownerRecords: self.ownerRecords.map { $0.toLeaderboardRecord() },
            records: self.records.map { $0.toLeaderboardRecord() }
        )
    }
}

extension Nakama_Api_Group {
    func toGroup() -> Group {
        return Group(
            id: self.id,
            creatorId: self.creatorID,
            name: self.name,
            description: self.description_p,
            langTag: self.langTag,
            metadata: self.metadata,
            avatarUrl: self.avatarURL,
            open: self.open.value,
            edgeCount: Int(self.edgeCount),
            maxCount: Int(self.maxCount),
            createTime: self.createTime.date,
            updateTime: self.updateTime.date
        )
    }
}

extension Nakama_Api_GroupList {
    func toGroupList() -> GroupList {
        return GroupList(
            groups: self.groups.map { $0.toGroup() },
            cursor: self.cursor
        )
    }
}

extension Nakama_Api_GroupUserList {
    func toGroupUserList() -> GroupUserList {
        return GroupUserList(
            cursor: self.cursor,
            groupUsers: self.groupUsers.map { $0.toGroupUser() }
        )
    }
}

extension Nakama_Api_GroupUserList.GroupUser {
    func toGroupUser() -> GroupUser {
        return GroupUser(
            state: Int(self.state.value),
            user: self.user.toApiUser()
        )
    }
}

extension Nakama_Api_UserGroupList.UserGroup {
    func toUserGroup() -> UserGroup {
        return UserGroup(
            state: Int(self.state.value),
            group: self.group.toGroup()
        )
    }
}

extension Nakama_Api_UserGroupList {
    func toUserGroupList() -> ListUserGroup {
        return ListUserGroup(
            cursor: self.cursor,
            userGroups: self.userGroups.map { $0.toUserGroup() })
    }
}

extension Nakama_Api_User {
    func toApiUser() -> ApiUser {
        return ApiUser(
            id: self.id,
            appleId: self.appleID,
            avatarUrl: self.avatarURL,
            createTime: self.createTime.date,
            displayName: self.displayName,
            edgeCount: Int(self.edgeCount),
            facebookId: self.facebookID,
            facebookInstantGameId: self.facebookInstantGameID,
            gamecenterId: self.gamecenterID,
            googleId: self.googleID,
            langTag: self.langTag,
            location: self.location,
            metadata: self.metadata,
            online: self.online,
            steamId: self.steamID,
            timezone: self.timezone,
            updateTime: self.updateTime.date,
            username: self.username
        )
    }
}

extension Nakama_Api_ValidatePurchaseResponse {
    func toValidatePurchaseResponse() -> ValidatePurchaseResponse {
        return ValidatePurchaseResponse(validatedPurchases: self.validatedPurchases.map { $0.toValidatedPurchase() })
    }
}

extension Nakama_Api_ValidatedPurchase {
    func toValidatedPurchase() -> ValidatedPurchase {
        return ValidatedPurchase(
            createTime: self.createTime.date,
            environment: self.environment,
            productId: self.productID,
            providerResponse: self.providerResponse,
            purchaseTime: self.purchaseTime.date,
            refundTime: self.refundTime.date,
            seenBefore: self.seenBefore,
            store: self.store,
            transactionId: self.transactionID,
            updateTime: self.updateTime.date,
            userId: self.userID
        )
    }
}

extension Nakama_Api_ValidatedSubscription {
    func toValidatedSubscription() -> ValidatedSubscription {
        return ValidatedSubscription(
            active: self.active,
            createTime: self.createTime.date,
            environment: self.environment,
            expiryTime: self.expiryTime.date,
            originalTransactionId: self.originalTransactionID,
            productId: self.productID,
            providerNotification: self.providerNotification,
            providerResponse: self.providerResponse,
            purchaseTime: self.purchaseTime.date,
            refundTime: self.refundTime.date,
            store: self.store,
            updateTime: self.updateTime.date,
            userId: self.userID
        )
    }
}

extension Nakama_Api_ValidateSubscriptionResponse {
    func toValidatedSubscriptionResponse() -> ValidateSubscriptionResponse {
        return ValidateSubscriptionResponse(validatedSubscription: self.validatedSubscription.toValidatedSubscription())
    }
}

extension Nakama_Api_SubscriptionList {
    func toSubscriptionList() -> SubscriptionList {
        return SubscriptionList(
            Cursor: self.cursor,
            PrevCursor: self.prevCursor,
            validatedSubscriptions: self.validatedSubscriptions.map { $0.toValidatedSubscription() }
        )
    }
}

extension Nakama_Api_NotificationList {
    func toNotificationList() -> NotificationList {
        return NotificationList(
            cacheableCursor: self.cacheableCursor,
            notifications: self.notifications.map { $0.toNotification() }
        )
    }
}

extension Nakama_Api_Notification {
    func toNotification() -> ApiNotification {
        return ApiNotification(
            code: Int(self.code),
            content: self.content,
            createTime: self.createTime.date,
            id: self.id,
            persistent: self.persistent,
            senderId: self.senderID,
            subject: self.subject
        )
    }
}

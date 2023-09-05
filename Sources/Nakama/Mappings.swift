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

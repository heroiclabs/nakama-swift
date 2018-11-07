/*
 * Copyright 2018 Heroic Labs
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


/**
 * Realtime message envelope.
 */
class WebSocketEnvelope: Codable, Envelope {
    func serialize(collationID: String) -> Data {
        cid = collationID
        let d = try! JSONEncoder().encode(self)
        let s = try! JSONDecoder().decode(WebSocketEnvelope.self, from: d)
        print(s.cid)
        print(String(data: d, encoding: .utf8))
        return d
    }

    static func deserialize(data: Data) -> WebSocketEnvelope {
        return try! JSONDecoder().decode(WebSocketEnvelope.self, from: data)

    }
    var cid: String?
    var error: WebSocketError?
    var rpc: RpcMessage?
    var channel: Channel?
    var channelJoin: ChannelJoinMessage?
    var channelLeave: ChannelLeaveMessage?
    var channelMessage: ChannelMessage?
    var channelMessageAck: ChannelMessageAck?
    var channelMessageSend: ChannelMessageSend?
    var channelMessageUpdate: ChannelMessageUpdate?
    var channelRemoveMessage: ChannelRemoveMessage?
    var channelPresenceEvent: ChannelPresenceEvent?
    var match: Match?
    var matchCreate: MatchCreateMessage?
    var matchData: MatchData?
    var matchDataSend: MatchSendMessage?
    var matchJoin: MatchJoinMessage?
    var matchLeave: MatchLeaveMessage?
    var matchPresenceEvent: MatchPresenceEvent?
    var matchmakerAdd: MatchmakerAddMessage?
    var matchmakerMatched: MatchmakerMatched?
    var matchmakerRemove: MatchmakerRemoveMessage?
    var matchmakerTicket: MatchmakerTicket?
    var notifications: NotificationList?
    var status: Status?
    var statusFollow: StatusFollowMessage?
    var statusPresenceEvent: StatusPresenceEvent?
    var statusUnfollow: StatusUnfollowMessage?
    var statusUpdate: StatusUpdateMessage?
    var streamData: StreamData?
    var streamPresenceEvent: StreamPresenceEvent?

    enum CodingKeys: String, CodingKey {
        case cid = "cid"
        case error = "error"
        case rpc = "rpc"
        case channel = "channel"
        case channelJoin = "channel_join"
        case channelLeave = "channel_leave"
        case channelMessage = "channel_message"
        case channelMessageAck = "channel_message_ack"
        case channelMessageSend = "channel_message_send"
        case channelMessageUpdate = "channel_message_update"
        case channelRemoveMessage = "channel_remove_message"
        case channelPresenceEvent = "channel_presence_event"

        case match = "match"
        case matchCreate = "match_create"
        case matchData = "match_data"
        case matchDataSend = "match_data_send"
        case matchJoin = "match_join"
        case matchLeave = "match_leave"
        case matchPresenceEvent = "match_presence_event"

        case matchmakerAdd = "matchmaker_add"
        case matchmakerMatched = "matchmaker_matched"
        case matchmakerRemove = "matchmaker_remove"
        case matchmakerTicket = "matchmaker_ticket"

        case notifications = "notifications"
        case status = "status"
        case statusFollow = "sttus_follow"
        case statusPresenceEvent = "status_presence_event"
        case statusUnfollow = "status_unfollow"
        case statusUpdate = "status_update"

        case streamData = "stream_data"
        case streamPresenceEvent = "stream_presence_event"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        cid = try values.decodeIfPresent(String.self, forKey: .cid)
        error = try values.decodeIfPresent(WebSocketError.self, forKey: .error)
        rpc = try values.decodeIfPresent(RpcMessage.self, forKey: .rpc)
        channel = try values.decodeIfPresent(Channel.self, forKey: .channel)
        channelJoin = try values.decodeIfPresent(ChannelJoinMessage.self, forKey: .channelJoin)
        channelLeave = try values.decodeIfPresent(ChannelLeaveMessage.self, forKey: .channelLeave)
        channelMessage = try values.decodeIfPresent(ChannelMessage.self, forKey: .channelMessage)
        channelMessageAck = try values.decodeIfPresent(ChannelMessageAck.self, forKey: .channelMessageAck)
        channelMessageSend = try values.decodeIfPresent(ChannelMessageSend.self, forKey: .channelMessageSend)
        channelMessageUpdate = try values.decodeIfPresent(ChannelMessageUpdate.self, forKey: .channelMessageUpdate)
        channelRemoveMessage = try values.decodeIfPresent(ChannelRemoveMessage.self, forKey: .channelRemoveMessage)
        channelPresenceEvent = try values.decodeIfPresent(ChannelPresenceEvent.self, forKey: .channelPresenceEvent)
        match = try values.decodeIfPresent(Match.self, forKey: .match)
        matchCreate = try values.decodeIfPresent(MatchCreateMessage.self, forKey: .matchCreate)
        matchData = try values.decodeIfPresent(MatchData.self, forKey: .matchData)
        matchDataSend = try values.decodeIfPresent(MatchSendMessage.self, forKey: .matchDataSend)
        matchJoin = try values.decodeIfPresent(MatchJoinMessage.self, forKey: .matchJoin)
        matchLeave = try values.decodeIfPresent(MatchLeaveMessage.self, forKey: .matchLeave)
        matchPresenceEvent = try values.decodeIfPresent(MatchPresenceEvent.self, forKey: .matchPresenceEvent)
        matchmakerAdd = try values.decodeIfPresent(MatchmakerAddMessage.self, forKey: .matchmakerAdd)
        matchmakerMatched = try values.decodeIfPresent(MatchmakerMatched.self, forKey: .matchmakerMatched)
        matchmakerRemove = try values.decodeIfPresent(MatchmakerRemoveMessage.self, forKey: .matchmakerRemove)
        matchmakerTicket = try values.decodeIfPresent(MatchmakerTicket.self, forKey: .matchmakerTicket)
        notifications = try values.decodeIfPresent(NotificationList.self, forKey: .notifications)
        status = try values.decodeIfPresent(Status.self, forKey: .status)
        statusFollow = try values.decodeIfPresent(StatusFollowMessage.self, forKey: .statusFollow)
        statusPresenceEvent = try values.decodeIfPresent(StatusPresenceEvent.self, forKey: .statusPresenceEvent)
        statusUnfollow = try values.decodeIfPresent(StatusUnfollowMessage.self, forKey: .statusUnfollow)
        statusUpdate = try values.decodeIfPresent(StatusUpdateMessage.self, forKey: .statusUpdate)
        streamData = try values.decodeIfPresent(StreamData.self, forKey: .streamData)
        streamPresenceEvent = try values.decodeIfPresent(StreamPresenceEvent.self, forKey: .streamPresenceEvent)

    }
    init(){

    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(cid, forKey: .cid)
        try container.encodeIfPresent(rpc, forKey: .rpc)
        try container.encodeIfPresent(channel, forKey: .channel)
        try container.encodeIfPresent(channelJoin, forKey: .channelJoin)
        try container.encodeIfPresent(channelLeave, forKey: .channelLeave)
        try container.encodeIfPresent(channelMessage, forKey: .channelMessage)
        try container.encodeIfPresent(channelMessageAck, forKey: .channelMessageAck)
        try container.encodeIfPresent(channelMessageSend, forKey: .channelMessageSend)
        try container.encodeIfPresent(channelMessageUpdate, forKey: .channelMessageUpdate)
        try container.encodeIfPresent(channelPresenceEvent, forKey: .channelPresenceEvent)

        try container.encodeIfPresent(match, forKey: .match)
        try container.encodeIfPresent(matchCreate, forKey: .matchCreate)
        try container.encodeIfPresent(matchData, forKey: .matchData)
        try container.encodeIfPresent(matchDataSend, forKey: .matchDataSend)
        try container.encodeIfPresent(matchJoin, forKey: .matchJoin)
        try container.encodeIfPresent(matchLeave, forKey: .matchLeave)
        try container.encodeIfPresent(matchPresenceEvent, forKey: .matchPresenceEvent)

        try container.encodeIfPresent(matchmakerAdd, forKey: .matchmakerAdd)
        try container.encodeIfPresent(matchmakerMatched, forKey: .matchmakerMatched)
        try container.encodeIfPresent(matchmakerRemove, forKey: .matchmakerRemove)
        try container.encodeIfPresent(matchmakerTicket, forKey: .matchmakerTicket)

        try container.encodeIfPresent(notifications, forKey: .notifications)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(statusFollow, forKey: .statusFollow)
        try container.encodeIfPresent(statusPresenceEvent, forKey: .statusPresenceEvent)
        try container.encodeIfPresent(statusUnfollow, forKey: .statusUnfollow)
        try container.encodeIfPresent(statusUpdate, forKey: .statusUpdate)

        try container.encodeIfPresent(streamData, forKey: .streamData)
        try container.encodeIfPresent(streamPresenceEvent, forKey: .streamPresenceEvent)


    }


}


public struct RpcMessage: CollatedMessage {
    let id: String
    let payload: String?
}

public struct WebSocketError: CollatedMessage {
    let code: Int
    let message: String
    let context: [String: String]?
}

/**
 * Send a channel join message to the server.
 */
public struct ChannelJoinMessage: CollatedMessage {
    let target: String
    let type: Int
    let hidden: Bool
    let persistence: Bool
}


/**
 * A leave message to a chat channel.
 */
public struct ChannelLeaveMessage: Message {

    let channelId: String

    enum CodingKeys: String, CodingKey {
        case channelId = "channel_id"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        channelId = try values.decode(String.self, forKey: .channelId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(channelId, forKey: .channelId)
    }
    public init(channelId: String){
        self.channelId = channelId
    }
}

/**
 * Send a chat message to a channel on the server.
 */
public struct ChannelMessageSend: CollatedMessage {
    let channelId: String
    let content: String


    enum CodingKeys: String, CodingKey {
        case channelId = "channel_id"
        case content = "content"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        channelId = try values.decode(String.self, forKey: .channelId)
        content = try values.decode(String.self, forKey: .content)



    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(channelId, forKey: .channelId)
        try container.encode(content, forKey: .content)
    }
    public init(channelId: String, content: String){
        self.channelId = channelId
        self.content = content
    }
}

/**
 * Update a chat message which has been sent to a channel.
 */
public struct ChannelMessageUpdate: CollatedMessage {
    let channelId: String
    let messageId: String
    let content: String

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case channelId = "channel_id"
        case content = "content"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try values.decode(String.self, forKey: .messageId)
        channelId = try values.decode(String.self, forKey: .channelId)
        content = try values.decode(String.self, forKey: .content)



    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(channelId, forKey: .channelId)
        try container.encode(content, forKey: .content)
    }
    public init(channelId: String, messageId: String, content: String){
        self.channelId = channelId
        self.content = content
        self.messageId = messageId
    }
}


/**
 * Update a chat message which has been sent to a channel.
 */
public struct ChannelRemoveMessage: CollatedMessage {
    let channelId: String
    let messageId: String

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case channelId = "channel_id"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try values.decode(String.self, forKey: .messageId)
        channelId = try values.decode(String.self, forKey: .channelId)



    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(channelId, forKey: .channelId)
    }

    public init(channelId: String, messageId: String){
        self.channelId = channelId
        self.messageId = messageId
    }
}

/**
 * A multiplayer match.
 */
public struct Match: CollatedMessage {
    /**
     * True if this match has an authoritative handler on the server.
     */
    let authoritative: Bool?
    /**
     * The unique match identifier.
     */
    let matchId: String?
    /**
     * A label for the match which can be filtered on.
     */
    let label: String?
    /**
     * The presences already in the match.
     */
    let presences: [UserPresence]?
    /**
     * The number of users currently in the match.
     */
    let size: Int?
    /**
     * The current user in this match. i.e. Yourself.
     */
    let me: UserPresence?


    enum CodingKeys: String, CodingKey {
        case authoritative = "authoritative"
        case matchId = "match_id"
        case label = "label"
        case presences = "presences"
        case size = "size"
        case me = "self"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        authoritative = try values.decodeIfPresent(Bool.self, forKey: .authoritative)
        matchId = try values.decodeIfPresent(String.self, forKey: .matchId)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        presences = try values.decodeIfPresent([UserPresence].self, forKey: .presences)
        size = try values.decodeIfPresent(Int.self, forKey: .size)
        me = try values.decodeIfPresent(UserPresence.self, forKey: .me)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(authoritative, forKey: .authoritative)
        try container.encodeIfPresent(matchId, forKey: .matchId)
        try container.encodeIfPresent(label, forKey: .label)
        try container.encodeIfPresent(presences, forKey: .presences)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(me, forKey: .me)
    }
}


public struct UserPresence: CollatedMessage {
    /**
     * True if this presence generates stored events like persistent chat messages or notifications.
     */
    let persistence: Bool?

    /**
     * The session id of the user.
     */
    let sessionId: String?

    /**
     * The status of the user with the presence on the server.
     */
    let status: String?

    /**
     * The username for the user.
     */
    let username: String?

    /**
     * The id of the user.
     */
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case persistence = "persistence"
        case sessionId = "session_id"
        case userName = "username"
        case userId = "user_id"
        case status = "status"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        persistence = try values.decodeIfPresent(Bool.self, forKey: .persistence)
        sessionId = try values.decodeIfPresent(String.self, forKey: .sessionId)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        username = try values.decodeIfPresent(String.self, forKey: .userName)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(persistence, forKey: .persistence)
        try container.encodeIfPresent(sessionId, forKey: .sessionId)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(username, forKey: .userName)
        try container.encodeIfPresent(userId, forKey: .userId)
    }
}

/**
 * A create message for a match on the server.
 */
public struct MatchCreateMessage: CollatedMessage {
}


/**
 * Some game state update in a match.
 */
public struct MatchData: CollatedMessage {
    /**
     * The unique match identifier.
     */
    let matchId: String

    /**
     * The operation code for the state change.
     * This value can be used to mark the type of the contents of the state.
     */
    var opCode: Int64?

    /**
     * the base-64 contents of the state change.
     */
    let data: String?

    /**
     * Information on the user who sent the state change.
     */
    let userPresence: UserPresence?

    enum CodingKeys: String, CodingKey {
        case matchId = "match_id"
        case opCode = "op_code"
        case data = "data"
        case userPresence = "presence"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        matchId = try values.decode(String.self, forKey: .matchId)
        if let op = try values.decodeIfPresent(String.self, forKey: .opCode){
            opCode = Int64(op)
        }
        userPresence = try values.decodeIfPresent(UserPresence.self, forKey: .userPresence)!
        data = try values.decodeIfPresent(String.self, forKey: .data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(matchId, forKey: .matchId)
        try container.encodeIfPresent(opCode, forKey: .opCode)
        try container.encodeIfPresent(userPresence, forKey: .userPresence)
        try container.encodeIfPresent(data, forKey: .data)

    }
    public init(matchId: String, opCode: Int64, data: String, presence: UserPresence?){
        self.matchId = matchId
        self.opCode = opCode
        self.userPresence = presence
        self.data = data
    }
}


/**
 * Send new state to a match on the server.
 */
public struct MatchSendMessage: CollatedMessage {
    let matchId: String
    let opCode: Int64
    let data: String
    let presences: [UserPresence]?

    enum CodingKeys: String, CodingKey {
        case matchId = "match_id"
        case opCode = "op_code"
        case data = "data"
        case presences = "presences"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        matchId = try values.decode(String.self, forKey: .matchId)
        opCode = try values.decode(Int64.self, forKey: .opCode)
        presences = try values.decodeIfPresent([UserPresence].self, forKey: .presences)!
        data = try values.decode(String.self, forKey: .data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(matchId, forKey: .matchId)
        try container.encode(opCode, forKey: .opCode)
        try container.encodeIfPresent(presences, forKey: .presences)
        try container.encode(data, forKey: .data)

    }
    public init(matchId: String, opCode: Int64, data: String, presences: [UserPresence]?){
        self.matchId = matchId
        self.opCode = opCode
        self.presences = presences
        self.data = data
    }
}


/**
 * A join message for a match on the server.
 */
public struct MatchJoinMessage: CollatedMessage {
    var matchId: String?
    var token: String?
}

/**
 * A leave message for a match on the server.
 */
public struct MatchLeaveMessage: CollatedMessage {
    let matchId: String
}


/**
 * A batch of join and leave presences for a match.
 */
public struct MatchPresenceEvent: CollatedMessage {
    /**
     * The unique match identifier.
     */
    var matchId: String?

    /**
     * Presences of users who joined the match.
     */
    var joins: [UserPresence]?

    /**
     * Presences of users who left the match.
     */
    var leaves: [UserPresence]?

    enum CodingKeys: String, CodingKey {
        case matchId = "match_id"
        case joins = "joins"
        case leaves = "leaves"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        matchId = try values.decodeIfPresent(String.self, forKey: .matchId)
        joins = try values.decodeIfPresent([UserPresence].self, forKey: .joins)
        leaves = try values.decodeIfPresent([UserPresence].self, forKey: .leaves)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(matchId, forKey: .matchId)
        try container.encodeIfPresent(joins, forKey: .joins)
        try container.encodeIfPresent(leaves, forKey: .leaves)

    }
}

/**
 * Add the user to the matchmaker pool with properties.
 */
public struct MatchmakerAddMessage: CollatedMessage {
    var minCount: Int?
    var maxCount: Int?
    var query: String?
    var numericProperties: [String: Double]?
    var stringProperties: [String: String]?

    enum CodingKeys: String, CodingKey {
        case minCount = "min_count"
        case maxCount = "max_count"
        case query = "query"
        case numericProperties = "numeric_properties"
        case stringProperties = "string_properties"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        minCount = try values.decodeIfPresent(Int.self, forKey: .minCount)
        maxCount = try values.decodeIfPresent(Int.self, forKey: .maxCount)
        query = try values.decodeIfPresent(String.self, forKey: .query)
        numericProperties = try values.decodeIfPresent([String: Double].self, forKey: .numericProperties)
        stringProperties = try values.decodeIfPresent([String: String].self, forKey: .stringProperties)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(minCount, forKey: .minCount)
        try container.encodeIfPresent(maxCount, forKey: .maxCount)
        try container.encodeIfPresent(query, forKey: .query)
        try container.encodeIfPresent(numericProperties, forKey: .numericProperties)
        try container.encodeIfPresent(stringProperties, forKey: .stringProperties)

    }
    public init (minCount: Int?, maxCount: Int?, query: String?, numericProperties:  [String: Double]? = nil,
                 stringProperties: [String: String]? = nil){
        self.minCount = minCount
        self.maxCount = maxCount
        self.query = query
        self.numericProperties = numericProperties
        self.stringProperties = stringProperties
    }
}

/**
 * The result of a successful matchmaker operation sent to the server.
 */
public struct MatchmakerMatched: CollatedMessage {
    /**
     * The id used to join the match.
     * A match ID used to join the match.
     */
    var matchId: String?
    /**
     * The ticket sent by the server when the user requested to matchmake for other players.
     */
    var ticket: String?
    /**
     * The token used to join a match.
     */
    var token: String?
    /**
     * The other users matched with this user and the parameters they sent.
     */
    var users: [MatchmakerUser]?
    /**
     * The current user who matched with opponents.
     */
    var me: MatchmakerUser?

    enum CodingKeys: String, CodingKey {
        case matchId = "match_id"
        case ticket = "ticket"
        case token = "token"
        case users = "users"
        case me = "self"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        matchId = try values.decodeIfPresent(String.self, forKey: .matchId)
        ticket = try values.decodeIfPresent(String.self, forKey: .ticket)
        token = try values.decodeIfPresent(String.self, forKey: .token)
        users = try values.decodeIfPresent([MatchmakerUser].self, forKey: .users)
        me = try values.decodeIfPresent(MatchmakerUser.self, forKey: .me)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(matchId, forKey: .matchId)
        try container.encodeIfPresent(ticket, forKey: .ticket)
        try container.encodeIfPresent(token, forKey: .token)
        try container.encodeIfPresent(users, forKey: .users)
        try container.encodeIfPresent(me, forKey: .me)


    }
}

/**
 * Remove the user from the matchmaker pool by ticket.
 */
public struct MatchmakerRemoveMessage: CollatedMessage {
    let ticket: String
}

/**
 * The matchmaker ticket received from the server.
 */
public struct MatchmakerTicket: CollatedMessage {
    /**
     * The ticket generated by the matchmaker.
     */
    var ticket: String
}

// This message type is only used for GSON, and not exposed to the Client interface.
public struct NotificationList: CollatedMessage {
    var notifications: [GRPCNotification]
    var cacheableCursor: String?

    enum CodingKeys: String, CodingKey {
        case notifications = "notifications"
        case cacheableCursor = "cacheable)cursor"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        notifications = try values.decode([GRPCNotification].self, forKey: .notifications)
        cacheableCursor = try values.decodeIfPresent(String.self, forKey: .cacheableCursor)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(notifications, forKey: .notifications)
        try container.encodeIfPresent(cacheableCursor, forKey: .cacheableCursor)

    }
}

/**
 * Receive status updates for users.
 */
public struct Status: CollatedMessage {
    /**
     * The status events for the users followed.
     */
    var presences: [UserPresence]?
}

/**
 * Follow one or more other users for status updates.
 */
public struct StatusFollowMessage: CollatedMessage {
    let userIds: [String]?

    enum CodingKeys: String, CodingKey {
        case userIds = "user_ids"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userIds = try values.decodeIfPresent([String].self, forKey: .userIds)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(userIds, forKey: .userIds)

    }
    public init(userIds: [String]){
        self.userIds = userIds
    }
}

/**
 * A status update event about other users who've come online or gone offline.
 */
public struct StatusPresenceEvent: CollatedMessage {

    /**
     * Presences of users who joined the server.
     *This join information is in response to a subscription made to be notified when a user comes online.
     */
    var joins: [UserPresence]?

    /**
     * Presences of users who left the server.
     * This leave information is in response to a subscription made to be notified when a user goes offline.
     */
    var leaves: [UserPresence]?
}

/**
 * Unfollow one or more other users for status updates.
 */
public struct StatusUnfollowMessage: CollatedMessage {
    let userIds: [String]?

    enum CodingKeys: String, CodingKey {
        case userIds = "user_ids"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userIds = try values.decodeIfPresent([String].self, forKey: .userIds)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(userIds, forKey: .userIds)

    }
    public init(userIds: [String]){
        self.userIds = userIds
    }
}

/**
 * Update the status of the current user.
 */
public struct StatusUpdateMessage: CollatedMessage {
    let status: String
}

/**
 * A state change received from a stream.
 */
public struct StreamData: CollatedMessage {
    /**
     * The user who sent the state change. May be <c>null</c>.
     */
    var sender: UserPresence?

    /**
     * The contents of the state change.
     */
    var data: String?

    /**
     * The identifier for the stream.
     */
    var stream: Stream?
}


/**
 * A batch of joins and leaves on the low level stream.
 * Streams are built on to provide abstractions for matches, chat channels, etc. In most cases you'll never need to
 * interact with the low level stream itself.
 */
public struct StreamPresenceEvent: CollatedMessage {
    /**
     * Presences of users who joined the stream.
     */
    var leaves: [UserPresence]?

    /**
     * Presences of users who left the stream.
     */
    var joins: [UserPresence]?

    /**
     * The identifier for the stream.
     */
    var stream: Stream?
}


/**
 * A chat channel on the server.
 */
public struct Channel: CollatedMessage {
    /**
     * The server-assigned channel ID.
     */
    var id: String
    /**
     * The presences visible on the chat channel.
     */
    var presences: [UserPresence]
    /**
     * The presence of the current user. i.e. Your self.
     */
    var me: UserPresence

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case presences = "presences"
        case me = "self"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        presences = try values.decode([UserPresence].self, forKey: .presences)
        me = try values.decode(UserPresence.self, forKey: .me)

    }
}


/**
 * A batch of join and leave presences on a chat channel.
 */
public struct ChannelPresenceEvent: CollatedMessage {
    /**
     * The unique identifier of the chat channel.
     */
    var channelId: String

    /**
     * The unique identifier of the chat channel.
     */
    var joins: [UserPresence]?

    /**
     * Presences of users who left the channel.
     */
    var leaves: [UserPresence]?


    enum CodingKeys: String, CodingKey {
        case channelId = "channel_id"
        case joins = "joins"
        case leaves = "leaves"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        channelId = try values.decode(String.self, forKey: .channelId)
        joins = try values.decodeIfPresent([UserPresence].self, forKey: .joins)
        leaves = try values.decodeIfPresent([UserPresence].self, forKey: .leaves)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(channelId, forKey: .channelId)
        try container.encodeIfPresent(joins, forKey: .joins)
        try container.encodeIfPresent(leaves, forKey: .leaves)

    }
}

/**
 * The user with the parameters they sent to the server when asking for opponents.
 */
public struct MatchmakerUser: CollatedMessage {
    /**
     * The numeric properties which this user asked to match make with.
     */
    var numericProperties: [String: Double]?
    /**
     * The presence of the user.
     */
    var presence: UserPresence?
    /**
     * The string properties which this user asked to matchMake with.
     */
    var stringProperties: [String: String]?

    enum CodingKeys: String, CodingKey {
        case numericProperties = "numeric_properties"
        case presence = "presence"
        case stringProperties = "string_properties"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        numericProperties = try values.decodeIfPresent([String: Double].self, forKey: .numericProperties)
        presence = try values.decodeIfPresent(UserPresence.self, forKey: .presence)
        stringProperties = try values.decodeIfPresent([String: String].self, forKey: .stringProperties)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(numericProperties, forKey: .numericProperties)
        try container.encodeIfPresent(presence, forKey: .presence)
        try container.encodeIfPresent(stringProperties, forKey: .stringProperties)

    }
}


/**
 * A notification object.
 */
public struct GRPCNotification: CollatedMessage {
    var id: String?
    var subject: String?
    var content: String?
    var code: Int?
    var senderId: String?
    var createTime: Date?
    var persistent: Bool?


    enum CodingKeys: String, CodingKey {
        case id = "id"
        case subject = "subject"
        case content = "content"
        case code = "code"
        case senderId = "sender_id"
        case createTime = "create_time"
        case persistent = "persistent"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        subject = try values.decodeIfPresent(String.self, forKey: .subject)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        content = try values.decodeIfPresent(String.self, forKey: .content)
        persistent = try values.decodeIfPresent(Bool.self, forKey: .persistent)
        if let createTimeString = try values.decodeIfPresent(String.self, forKey: .createTime) {
            createTime = createTimeString.dateFromISO8601
        }
        senderId = try values.decodeIfPresent(String.self, forKey: .senderId)

    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(subject, forKey: .subject)
        try container.encodeIfPresent(code, forKey: .code)
        try container.encodeIfPresent(content, forKey: .content)
        try container.encodeIfPresent(persistent, forKey: .persistent)
        if let createTimePresent = createTime {
            try container.encodeIfPresent(createTimePresent.iso8601, forKey: .createTime)
        }
        try container.encodeIfPresent(senderId, forKey: .senderId)
    }
}

/**
 * A realtime socket stream on the server.
 */
public struct Stream: CollatedMessage {

    /**
     * The descriptor of the stream. Used with direct chat messages and contains a second user id.
     */
    private var descriptor: String?

    /**
     * Identifies streams which have a context across users like a chat channel room.
     */
    private var label: String?

    /**
     * The mode of the stream.
     */
    private var mode: Int?

    /**
     * The subject of the stream. This is usually a user id.
     */
    private var subject: String?
}


/**
 * An acknowledgement from the server when a chat message is delivered to a channel.
 */
public struct ChannelMessageAck: CollatedMessage {
    /**
     * A unique ID for the chat message.
     */
    var messageId: String?

    /**
     * The server-assigned channel ID.
     */
    var channelId: String?

    /**
     * A user-defined code for the chat message.
     */
    var code: Int?

    /**
     * The username of the sender of the message.
     */
    var username: String?

    /**
     * True if the chat message has been stored in history.
     */
    var persistent: Bool?

    /**
     * The UNIX time when the message was created.
     */
    var createTime: Date?

    /**
     * The UNIX time when the message was updated.
     */
    var updateTime: Date?

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case channelId = "channel_id"
        case code = "code"
        case username = "username"
        case persistent = "persistent"
        case createTime = "create_time"
        case updateTime = "update_time"
    }


    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try values.decodeIfPresent(String.self, forKey: .messageId)
        channelId = try values.decodeIfPresent(String.self, forKey: .channelId)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        persistent = try values.decodeIfPresent(Bool.self, forKey: .persistent)
        if let createTimeString = try values.decodeIfPresent(String.self, forKey: .createTime) {
            createTime = createTimeString.dateFromISO8601
        }
        if let updateTimeString = try values.decodeIfPresent(String.self, forKey: .updateTime){
            updateTime = updateTimeString.dateFromISO8601
        }


    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(messageId, forKey: .messageId)
        try container.encodeIfPresent(channelId, forKey: .channelId)
        try container.encodeIfPresent(code, forKey: .code)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(persistent, forKey: .persistent)
        if let createTimePresent = createTime {
            try container.encodeIfPresent(createTimePresent.iso8601, forKey: .createTime)
        }
        if let updateTimePresent = updateTime {
            try container.encodeIfPresent(updateTimePresent.iso8601, forKey: .updateTime)
        }
    }
}

/**
 * A message sent on a channel.
 *
 */
// This message type is only used for GSON, and not exposed to the Client interface.
public struct ChannelMessage: CollatedMessage {
    var channelId: String?
    var messageId: String?
    var code: Int?
    var senderId: String?
    var username: String?
    var content: String?
    var createTime: Date?
    var updateTime: Date?
    var persistent: Bool?

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case channelId = "channel_id"
        case code = "code"
        case username = "username"
        case persistent = "persistent"
        case createTime = "create_time"
        case updateTime = "update_time"
        case senderId = "sender_id"
        case content = "content"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try values.decodeIfPresent(String.self, forKey: .messageId)
        channelId = try values.decodeIfPresent(String.self, forKey: .channelId)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        persistent = try values.decodeIfPresent(Bool.self, forKey: .persistent)
        if let createTimeString = try values.decodeIfPresent(String.self, forKey: .createTime) {
            createTime = createTimeString.dateFromISO8601
        }
        if let updateTimeString = try values.decodeIfPresent(String.self, forKey: .updateTime){
            updateTime = updateTimeString.dateFromISO8601
        }
        senderId = try values.decodeIfPresent(String.self, forKey: .senderId)
        content = try values.decodeIfPresent(String.self, forKey: .content)



    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(messageId, forKey: .messageId)
        try container.encodeIfPresent(channelId, forKey: .channelId)
        try container.encodeIfPresent(code, forKey: .code)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(persistent, forKey: .persistent)
        if let createTimePresent = createTime {
            try container.encodeIfPresent(createTimePresent.iso8601, forKey: .createTime)
        }
        if let updateTimePresent = updateTime {
            try container.encodeIfPresent(updateTimePresent.iso8601, forKey: .updateTime)
        }
        try container.encodeIfPresent(senderId, forKey: .senderId)
        try container.encodeIfPresent(content, forKey: .content)
    }
}


public enum ChannelType: Int, Codable {
    case room = 0
    case directMessage = 1
    case group = 2
    case unknown = 3

    internal static func make(from code: Int) -> ChannelType {
        switch code {
        case 0:
            return .room
        case 1:
            return .directMessage
        case 2:
            return .group
        default:
            return .unknown
        }
    }
}

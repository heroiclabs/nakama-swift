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

public typealias ConnectHandler = (() -> Void)
public typealias DisconnectHandler = (() -> Void)
public typealias SocketErrorHandler = ((Error) -> ())
public typealias ChannelMessageHandler = ((Nakama_Api_ChannelMessage) -> ())
public typealias ChannelPresenceHandler = ((Nakama_Realtime_ChannelPresenceEvent) -> ())
public typealias MatchmakerMatchedHandler = ((Nakama_Realtime_MatchmakerMatched) -> ())
public typealias MatchDataHandler = ((Nakama_Realtime_MatchData) -> ())
public typealias MatchPresenceHandler = ((Nakama_Realtime_MatchPresenceEvent) -> ())
public typealias NotificationsHandler = ((Nakama_Realtime_Notifications) -> ())
public typealias StatusPresenceHandler = ((Nakama_Realtime_StatusPresenceEvent) -> ())
public typealias StreamPresenceHandler = ((Nakama_Realtime_StreamPresenceEvent) -> ())
public typealias StreamDataHandler = ((Nakama_Realtime_StreamData) -> ())

enum SocketError: Error {
    case timeout
    case invalidDataFormat(String)
    
    init(_ message: String) {
        self = .invalidDataFormat(message)
    }
}

public struct NakamaRealtimeError: LocalizedError {
    /// Human-readable error
    public var errorDescription: String
    
    /// The error code which should be one of "Error.Code" enums.
    public let code: Nakama_Realtime_Error.Code?
    
    /// A message in English to help developers debug the response.
    public let message: String?
    
    /// Additional error details which may be different for each response.
    public let context: Dictionary<String,String>?
    
    init(text: String) {
        self.errorDescription = text
        self.code = nil
        self.message = nil
        self.context = nil
    }
    
    init(error: Error) {
        self.errorDescription = error.localizedDescription
        self.code = nil
        self.message = nil
        self.context = nil
    }
    
    init(error: Nakama_Realtime_Error) {
        self.errorDescription = "\(error.code): \(error.message)"
        self.code = Nakama_Realtime_Error.Code(rawValue: Int(error.code))
        self.message = error.message
        self.context = error.context
    }
}

public protocol SocketClient {
    /**
     Host to connect to.
     */
    var host: String { get }
    /**
     Port to connect to.
     */
    var port: Int { get }
    /**
     Whether SSL should be used to connect with.
     */
    var ssl: Bool { get }
    
    /**
     If set, will notify when connection was established.
     */
    var onConnect: ConnectHandler? { get set }
    
    /**
     If set, will notify when socket was disconnected.
     */
    var onDisconnect: DisconnectHandler? { get set }
    
    /**
     If set, will notify when socket was disconnected.
     */
    var onError: SocketErrorHandler? { get set }
    
    /**
     Called when a new topic message has been received.
     */
    var onChannelMessage: ChannelMessageHandler? { get set }
    
    /**
     Called when a new topic presence update has been received.
     */
    var onChannelPresence: ChannelPresenceHandler? { get set }
    
    /**
     Called when a matchmaking has found a match.
     */
    var onMatchmakerMatched: MatchmakerMatchedHandler? { get set }
    
    /**
     Called when a new match data is received.
     */
    var onMatchData: MatchDataHandler? { get set }
    
    /**
     Called when a new match presence update is received.
     */
    var onMatchPresence: MatchPresenceHandler? { get set }
    
    /**
     Called when the client receives new notifications.
     */
    var onNotifications: NotificationsHandler? { get set }
    
    /**
     Called when the client receives status presence updates.
     */
    var onStatusPresence: StatusPresenceHandler? { get set }
    
    /**
     Called when the client receives stream presence updates.
     */
    var onStreamPresence: StreamPresenceHandler? { get set }
    
    /**
     Called when the client receives stream data.
     */
    var onStreamData: StreamDataHandler? { get set }
    
    /// If the socket is connected.
    var isConnected: Bool { get }
    
    /// If the socket is connecting.
    var isConnecting: Bool { get }
    
    /**
     Connect to the server.
     - Parameter session: The session of the user.
     - Parameter appearOnline: If the user should appear online to other users.
     */
    func connect(session: Session, appearOnline: Bool?)
    
    /// Close the connection with the server.
    func disconnect()
    
    /**
     Join a chat channel on the server.
     - Parameter target: The target channel to join.
     - Parameter type: The type of channel to join.
     - Parameter persistence: True if chat messages should be stored.
     - Parameter hidden: True if the user should be hidden on the channel.
     - Returns: A Nakama realtime channel.
     */
    func joinChat(target: String, type: Nakama_Realtime_ChannelJoin.TypeEnum, persistence: Bool?, hidden: Bool?) async throws -> NakamaChannel
    
    /**
     Leave a chat channel on the server.
     - Parameter channelId: The channel to leave.
     */
    func leaveChat(channelId: String) async throws -> Void
    
    /**
     Remove a chat message from a channel on the server.
     - Parameter channelId: The chat channel with the message.
     - Parameter messageId: The ID of a chat message to update.
     */
    func removeChatMessage(channelId: String, messageId: String) async throws -> Nakama_Realtime_ChannelMessageAck
    
    /**
     Send a chat message to a channel on the server.
     - Parameter channelId: The channel to send on.
     - Parameter content: The content of the chat message.
     */
    func writeChatMessage(channelId: String, content: String) async throws -> Nakama_Realtime_ChannelMessageAck
    
    /**
     Update a chat message to a channel on the server.
     - Parameter channelId: The ID of the chat channel with the message.
     - Parameter messageId: The ID of the message to update.
     - Parameter content: The content update for the message.
     */
    func updateChatMessage(channelId: String, messageId: String, content: String) async throws -> Nakama_Realtime_ChannelMessageAck
    
    /// Create a multiplayer match on the server.
    func createMatch() async throws -> Nakama_Realtime_Match
    
    /**
     Join a multiplayer match by ID.
     - Parameter matchId: A match ID.
     - Parameter metadata: An optional set of key-value metadata pairs to be passed to the match handler, if any.
     - Returns: The match joined.
     */
    func joinMatch(matchId: String, metadata: [String:String]?) async throws -> Nakama_Realtime_Match
    
    /**
     Join a multiplayer match with a matchmaker.
     - Parameter token: A matchmaker ticket result object.
     */
    func joinMatchToken(token: String) async throws -> Nakama_Realtime_Match
    
    /**
     Leave a match on the server.
     - Parameter matchId: The match to leave.
     */
    func leaveMatch(matchId: String) async throws -> Void
    
    /**
     Join the matchmaker pool and search for opponents on the server.
     - Parameter query: A matchmaker query to search for opponents.
     - Parameter minCount: The minimum number of players to compete against.
     - Parameter maxCount: The maximum number of players to compete against.
     - Parameter stringProperties: A set of k/v properties to provide in searches.
     - Parameter numericProperties: A set of k/v numeric properties to provide in searches.
     - Parameter countMultiple: An optional integer to force the matchmaker to match in multiples of.
     */
    func addMatchmaker(query: String?, minCount: Int32?, maxCount: Int32?, stringProperties: [String:String]?, numericProperties: [String:Double]?, countMultiple: Int?) async throws -> Nakama_Realtime_MatchmakerTicket
    
    /**
     Leave the matchmaker pool by ticket.
     - Parameter ticket: The ticket returned by the matchmaker on join.
     */
    func removeMatchmaker(ticket: String) async throws -> Void
    
    /**
     Send a state change to a match on the server.
     
     When no presences are supplied the new match state will be sent to all presences.
     - Parameter matchId: The Id of the match.
     - Parameter opCode: An operation code for the match state.
     - Parameter data: The new state to send to the match.
     - Parameter presences: The presences in the match to send the state.
     */
    func sendMatchData(matchId: String, opCode: Int64, data: Data, presences: [Nakama_Realtime_UserPresence]?)
    
    /**
     Send an RPC message to the server.
     - Parameter id The ID of the function to execute.
     - Parameter payload The content: String to send to the server.
     */
    func rpc(id: String, payload: String?) async throws -> Nakama_Api_Rpc
    
    /**
     Follow one or more users for status updates.
     - Parameter userIds: The user Ids to follow.
     */
    func followUsers(userIds: String...) async throws -> Nakama_Realtime_Status
    
    /**
     Follow one or more users for status updates.
     - Parameter userIds: The user Ids to follow.
     - Parameter usernames: Usernames to follow.
     */
    func followUsers(userIds: [String]?, usernames: [String]?) async throws -> Nakama_Realtime_Status
    
    /**
     Unfollow status updates for one or more users.
     - Parameter userIds: The ids of users to unfollow.
     */
    func unfollowUsers(userIds: String...) async throws -> Void
    
    /**
     Update the user's status online.
     - Parameter status: The new status of the user.
     */
    func updateStatus(status: String) async throws -> Void
}

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
import os

import PromiseKit
import Starscream


/**
 A message which requires no acknowledgement by the server.
 */
public protocol Message: Codable {
}


/**
 A message which returns a response from the server.
 
 - Parameter <T>: The type of the message response.
 */
public protocol CollatedMessage: Codable {
}

/**
 A message which returns a response from the server.
 
 - Parameter <T>: The type of the message response.
 */
public protocol Envelope: CollatedMessage {
    /**
     - Parameter collationId: The collation ID to assign to the serialized message instance.
     - Returns: The serialized format of the message.
     */
    func serialize(collationID: String) -> Data

}

public class Builder {
    private let serverKey: String
    private var host: String = "127.0.0.1"
    private var port: Int = 7350
    private var lang: String = "en"
    private var ssl: Bool = false
    private var timeout: Int = 5000
    private var trace: Bool = false

    public init(serverKey: String) {
        self.serverKey = serverKey
    }

    public func build() -> Client {
        return DefaultClient(serverKey: serverKey, host: host, port: port, lang: lang, ssl: ssl, timeout: timeout, trace: trace)
    }

    public func host(_ host: String) -> Builder {
        self.host = host
        return self
    }

    public func port(_ port: Int) -> Builder {
        self.port = port
        return self
    }

    public func lang(_ lang: String) -> Builder {
        self.lang = lang
        return self
    }

    public func ssl(_ ssl: Bool) -> Builder {
        self.ssl = ssl
        return self
    }

    public func timeout(_ timeout: Int) -> Builder {
        self.timeout = timeout
        return self
    }

    public func trace(_ trace: Bool) -> Builder {
        self.trace = trace
        return self
    }

    public class func defaults(serverKey: String) -> Client {
        return Builder(serverKey: serverKey).build()
    }
}

/**
 A client for the Nakama server.
 */
public protocol Client {
    /**
     - Returns: The current server time in UTC milliseconds as reported by the server
     during the last heartbeat exchange. If this client has never been
     connected the function returns local device current UTC milliseconds.
     */
    var serverTime: Int { get }

    /**
     This is invoked when the socket connection has been disconnected
     */
    var onDisconnect: ((Error?) -> Void)? { get set }

    /**
     This is invoked when there is a server error.
     */
    var onError: ((NakamaError) -> Void)? { get set }

    /**
     This is invoked when a new channel message is received.
     */
    var onChannelMessage: ((ChannelMessage) -> Void)? { get set }

    /**
     This is invoked when a new topic presence update is received.
     */
    var onChannelPresence: ((ChannelPresenceEvent) -> Void)? { get set }

    /**
    This is invoked when a matchmaking has found a match
    */
    var onMatchMakerMatched: ((MatchmakerMatched) -> Void)? { get set }

    /**
     This is invoked when an new match presence  is recevied
    */
    var onMatchData: ((MatchData) -> Void)? { get set }

    /**
     This is invoked when an ew match data  is recevied
     */
    var onMatchPresence: ((MatchPresenceEvent) -> Void)? { get set }
//
    /**
     This is invoked when a new notification is received.
     */
    var onNotification: ((Notification) -> Void)? { get set }

    /**
     This is invoked when a new status presence update is received
    */
    var onStatusPresence: ((StatusPresenceEvent) -> Void)? { get set }

    /**
     This is invoked when a new stream presence updates
    */
    var onStreamPresence: ((StreamPresenceEvent) -> Void)? { get set }

    /**
     This is invoked when a new stream data is received
     */
    var onStreamData: ((StreamData) -> Void)? { get set }
//

    /**
     - Sends a disconnect request to the server. When disconnected, `onDisconnect` is invoked.
     */
    func disconnect()

    /**
     - Send a logout request to the server
     */
    func logout()

    /**
     Join a chat channel on the server.
    
     - Parameter target The target channel to join.
     - Parameter type The type of channel to join.
     - Returns: A future which resolves to a Channel response.
     */
    func joinChat(targetChannelId: String, channelType: ChannelType) -> Promise<Channel>

    /**
     Join a chat channel on the server.
    
     - Parameter target The target channel to join.
     - Parameter type The type of channel to join.
     - Parameter persistence True if chat messages should be stored.
     - Returns: A future which resolves to a Channel response.
     */
    func joinChat(targetChannelId: String, channelType: ChannelType, IsPersisted: Bool) -> Promise<Channel>
    /**
     Join a chat channel on the server.
    
     - Parameter target The target channel to join.
     - Parameter type The type of channel to join.
     - Parameter persistence True if chat messages should be stored.
     - Parameter hidden True if the user should be hidden on the channel.
     - Returns: A future which resolves to a Channel response.
     */
    func joinChat(targetChannelId: String, channelType: ChannelType, IsPersisted: Bool, IsHidden: Bool) -> Promise<Channel>

    /**
     Leave a chat channel on the server.
    
     - Parameter channelId The channel to leave.
     - Returns: A future.
     */
    func leaveChat(targetChannelId: String)

    /**
     Remove a chat message from a channel on the server.
    
     - Parameter channelId The chat channel with the message.
     - Parameter messageId The ID of a chat message to update.
     - Returns: A future.
     */
    func removeChatMessage(channelId: String, messageId: String) -> Promise<ChannelMessageAck>

    /**
     Send a chat message to a channel on the server.
    
     - Parameter channelId The channel to send on.
     - Parameter content The content of the chat message.
     - Returns: A future which resolves to a Channel Ack response.
     */
    func writeChatMessage(channelId: String, content: String) -> Promise<ChannelMessageAck>


    /**
     Update a chat message to a channel on the server.
    
     - Parameter channelId The ID of the chat channel with the message.
     - Parameter messageId The ID of the message to update.
     - Parameter content The content update for the message.
     - Returns: A future.
     */
    func updateChatMessage(channelId: String, messageId: String, content: String) -> Promise<ChannelMessageAck>

    /**
     - Parameter message : message The message to send.
     */
    func send(message: Message)

    /**
     Create a multiplayer match on the server.
    
     - Returns: A future.
     */
    func createMatch() -> Promise<Match>

    /**
     Join a multiplayer match by ID.
    
     - Parameter matchId A match ID.
     - Returns: A future which resolves to the match joined.
     */
    func joinMatch(token: String) -> Promise<Match>

    /**
    Join a multiplayer match with a matchmaker.
   
    - Parameter token A matchmaker ticket result object.
    - Returns: A future which resolves to the match joined.
    */
    func joinMatch(matchId: String) -> Promise<Match>

    /**
     Leave a match on the server.
    
     - Parameter matchId The match to leave.
     - Returns: A future.
     */
    func leaveMatch(matchId: String) -> Promise<Void>

    /**
     Join the matchmaker pool and search for opponents on the server.
    
     - Parameter query A matchmaker query to search for opponents.
     - Parameter minCount The minimum number of players to compete against.
     - Parameter maxCount The maximum number of players to compete against.
     - Parameter stringProperties A set of k/v properties to provide in searches.
     - Parameter numericProperties A set of k/v numeric properties to provide in searches.
     - Returns: A future which resolves to a matchmaker ticket object.
     */
    func addMatchMaker(minCount: Int?, maxCount: Int?, query: String?, stringProperties: [String: String]?, numericProperties: [String: Double]?) -> Promise<MatchmakerTicket>

    /**
     Leave the matchmaker pool by ticket.
    
     - Parameter ticket The ticket returned by the matchmaker on join. See <c>IMatchmakerTicket.Ticket</c>.
     - Returns: A future.
     */
    func removeMatchMaker(ticket: String) -> Promise<Void>

    /**
     Send a state change to a match on the server.
    
     When no presences are supplied the new match state will be sent to all presences.
    
     - Parameter matchId The Id of the match.
     - Parameter opCode An operation code for the match state.
     - Parameter data The new state to send to the match.
     - Parameter presences The presences in the match to send the state.
     */
    func sendMatchData(matchId: String, opCode: Int64, data: Data, presences: [UserPresence]?) -> Promise<Void>

    /**
     Send an RPC message to the server.
    
     - Parameter id The ID of the function to execute.
     - Parameter payload The string content to send to the server.
     - Returns: A future which resolves to an RPC response.
     */
    func rpc(id: String, payload: String?) -> Promise<RpcMessage>

    /**
     Follow one or more users for status updates.
    
     - Parameter userIds The user Ids to follow.
     - Returns: A future.
     */
    func followUsers(userIds: [String]) -> Promise<Status>

    /**
     Unfollow status updates for one or more users.
    
     - Parameter userIds The ids of users to unfollow.
     - Returns: A future.
     */
    func unfollowUsers(userIds: [String]) -> Promise<Void>

    /**
     Update the user's status online.
    
     - Parameter status The new status of the user.
     - Returns: A future.
     */
    func updateStatus(status: String) -> Promise<Void>

    /**
     Connect to the server.
     - Parameter session The session of the user.
     - Parameter listener An event listener to notify on updates.
     - Parameter createStatus True if the socket should show the user as online to others.
     - Returns: A future.
     */
    func createSocket(to session: Session) -> Promise<Session>


    func loginOrRegister(with deviceID: String) -> Promise<Session>
}

internal class DefaultClient: Client, WebSocketDelegate {

    private let serverKey: String
    private let lang: String
    private let timeout: Int
    private let trace: Bool
    private let grpcClient: Nakama_Api_NakamaServiceClient

    private var wsComponent: URLComponents
    private var socket: WebSocket?
    private var collationIDs = [String: Any]()
    private var _serverTime: Int = 0

    var onDisconnect: ((Error?) -> Void)?
    var onError: ((NakamaError) -> Void)?
    var onNotification: ((Notification) -> Void)?
    var onChannelMessage: ((ChannelMessage) -> Void)?
    var onChannelPresence: ((ChannelPresenceEvent) -> Void)?
    var onMatchMakerMatched: ((MatchmakerMatched) -> Void)?
    var onMatchData: ((MatchData) -> Void)?
    var onMatchPresence: ((MatchPresenceEvent) -> Void)?
    var onStatusPresence: ((StatusPresenceEvent) -> Void)?
    var onStreamPresence: ((StreamPresenceEvent) -> Void)?
    var onStreamData: ((StreamData) -> Void)?


    var serverTime: Int {
        return self._serverTime != 0 ? self._serverTime : Int(Date().timeIntervalSince1970 * 1000.0);
    }

    internal init(serverKey: String, host: String, port: Int, lang: String,
                  ssl: Bool, timeout: Int, trace: Bool) {

        self.serverKey = serverKey
        self.lang = lang
        self.timeout = timeout
        self.trace = trace

        self.wsComponent = URLComponents()
        self.wsComponent.host = host
        self.wsComponent.port = 7350
        self.wsComponent.scheme = ssl ? "https" : "ws"
        self.wsComponent.path = "/ws"

        //set up the gRPC client
        self.grpcClient = Nakama_Api_NakamaServiceClient.init(address: "\(host):\(port)", secure: ssl)
        let basicAuth = "\(serverKey)"
        let authValue = "Basic " + basicAuth.data(using: .utf8)!.base64EncodedString()
        try? self.grpcClient.metadata.add(key: "authorization", value: authValue)
    }

    func joinChat(targetChannelId: String, channelType: ChannelType) -> Promise<Channel> {
        let msg = ChannelJoinMessage(target: targetChannelId, type: channelType.rawValue, hidden: false, persistence: true)
        let env = WebSocketEnvelope()
        env.channelJoin = msg
        return self.send(proto: env)
    }

    func joinChat(targetChannelId: String, channelType: ChannelType, IsPersisted: Bool) -> Promise<Channel> {
        let msg = ChannelJoinMessage(target: targetChannelId, type: channelType.rawValue, hidden: false, persistence: IsPersisted)
        let env = WebSocketEnvelope()
        env.channelJoin = msg
        return self.send(proto: env)
    }

    func joinChat(targetChannelId: String, channelType: ChannelType, IsPersisted: Bool, IsHidden: Bool) -> Promise<Channel> {
        let msg = ChannelJoinMessage(target: targetChannelId, type: channelType.rawValue, hidden: IsHidden, persistence: IsPersisted)
        let env = WebSocketEnvelope()
        env.channelJoin = msg
        return self.send(proto: env)
    }

    func leaveChat(targetChannelId: String) {
        let msg = ChannelLeaveMessage(channelId: targetChannelId)
        let env = WebSocketEnvelope()
        env.channelLeave = msg
        self.send(message: msg)

    }

    func removeChatMessage(channelId: String, messageId: String) -> Promise<ChannelMessageAck> {
        let msg = ChannelRemoveMessage(channelId: channelId, messageId: messageId)
        let env = WebSocketEnvelope()
        env.channelRemoveMessage = msg
        return self.send(proto: env)

    }

    func writeChatMessage(channelId: String, content: String) -> Promise<ChannelMessageAck> {
        let msg = ChannelMessageSend(channelId: channelId, content: content)
        let env = WebSocketEnvelope()
        env.channelMessageSend = msg
        return self.send(proto: env)
    }

    func updateChatMessage(channelId: String, messageId: String, content: String) -> Promise<ChannelMessageAck> {
        let msg = ChannelMessageUpdate(channelId: channelId, messageId: messageId, content: content)
        let env = WebSocketEnvelope()
        env.channelMessageUpdate = msg
        return self.send(proto: env)
    }

    func createMatch() -> Promise<Match> {
        let msg = MatchCreateMessage()
        let env = WebSocketEnvelope()
        env.matchCreate = msg
        return self.send(proto: env)
    }

    func joinMatch(matchId: String) -> Promise<Match> {
        let msg = MatchJoinMessage(matchId: matchId, token: nil)
        let env = WebSocketEnvelope()
        env.matchJoin = msg
        return self.send(proto: env)
    }

    func joinMatch(token: String) -> Promise<Match> {
        let msg = MatchJoinMessage(matchId: nil, token: token)
        let env = WebSocketEnvelope()
        env.matchJoin = msg
        return self.send(proto: env)
    }

    func leaveMatch(matchId: String) -> Promise<Void> {
        let msg = MatchLeaveMessage(matchId: matchId)
        let env = WebSocketEnvelope()
        env.matchLeave = msg
        return self.send(proto: env)
    }

    func addMatchMaker(minCount: Int?, maxCount: Int?, query: String?, stringProperties: [String: String]?, numericProperties: [String: Double]?) -> Promise<MatchmakerTicket> {
        let msg = MatchmakerAddMessage(minCount: minCount, maxCount: maxCount, query: query,
                                       numericProperties: numericProperties, stringProperties: stringProperties)

        let env = WebSocketEnvelope()
        env.matchmakerAdd = msg
        return self.send(proto: env)
    }

    func removeMatchMaker(ticket: String) -> Promise<Void> {
        let msg = MatchmakerRemoveMessage(ticket: ticket)
        let env = WebSocketEnvelope()
        env.matchmakerRemove = msg
        return self.send(proto: env)
    }

    func sendMatchData(matchId: String, opCode: Int64, data: Data, presences: [UserPresence]?) -> Promise<Void> {
        let p = presences != nil ? presences : [UserPresence]()
        let msg = MatchSendMessage(matchId: matchId, opCode: opCode, data: data.base64EncodedString(), presences: p!)

        let env = WebSocketEnvelope()
        env.matchDataSend = msg
        return self.send(proto: env)
    }

    func rpc(id: String, payload: String?) -> Promise<RpcMessage> {
        let msg = RpcMessage(id: id, payload: payload)
        let env = WebSocketEnvelope()
        env.rpc = msg
        return  self.send(proto: env)
    }

    func followUsers(userIds: [String]) -> Promise<Status> {
        let msg = StatusFollowMessage(userIds: userIds)
        let env = WebSocketEnvelope()
        env.statusFollow = msg
        return  self.send(proto: env)
    }

    func unfollowUsers(userIds: [String]) -> Promise<Void> {
        let msg = StatusUnfollowMessage(userIds: userIds)
        let env = WebSocketEnvelope()
        env.statusUnfollow = msg
        return  self.send(proto: env)
    }

    func updateStatus(status: String) -> Promise<Void> {
        let msg = StatusUpdateMessage(status: status)
        let env = WebSocketEnvelope()
        env.statusUpdate = msg
        return  self.send(proto: env)
    }


    func logout() {
//        self.send(message: LogoutMessage.init())
    }

    func websocketDidConnect(socket: WebSocketClient) {
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("DISONNECTED ************************")
        self.collationIDs.removeAll()
        if self.onDisconnect != nil {
            self.onDisconnect!(error)
        }
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("TEXT RECEVIVED@@@@@@@@@@@@@@@@@@")
        print(text)
        processText(text: text)
//        process(data: text.data(using: .utf8)!)
        if trace {
            NSLog("Unexpected string message from server: %@", text);
        }
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("DATA RECEVIVED@@@@@@@@@@@@@@@@@@")
        print(data)
        process(data: data)
    }


    func loginOrRegister(with deviceID: String) -> Promise<Session> {
        //let's authenitcate using the device id

        var message = Nakama_Api_AuthenticateDeviceRequest.init()
        message.account = Nakama_Api_AccountDevice.init()
        message.account.id = deviceID
        message.username = deviceID
        message.create = true
        let (p, seal) = Promise<Session>.pending()
        _ = try? self.grpcClient.authenticateDevice(message, completion: { (session, rsp) in
            if rsp.success {
                seal.fulfill(DefaultSession(token: session!.token, created: session!.created))
            } else {
                seal.reject(NakamaError.runtimeException(String(format: "Internal Server Error - HTTP %@", rsp.statusCode.rawValue)))
            }

        })
        return p
    }

    func createSocket(to session: Session) -> Promise<Session> {
        if (socket != nil) {
            precondition(socket!.isConnected, "socket is already connected")
        }

        let (promise, seal) = Promise<Session>.pending()

        wsComponent.queryItems = [
            URLQueryItem.init(name: "token", value: session.authToken),
            URLQueryItem.init(name: "status", value: session.created.description),
            URLQueryItem.init(name: "lang", value: lang)
        ]

        socket = WebSocket(url: wsComponent.url!)

        socket!.delegate = self
        socket!.enableCompression = true
        socket!.onConnect = {
            print("ONCONNECT************")
            print(session)
            if promise.isPending {
                seal.fulfill(session)
            }
        }
        socket!.onDisconnect = { error in
            print("DISCONNECT(((((((()))))))")
            print(error)
            if promise.isPending {
                seal.reject(error ?? NSError(domain: NakamaError.Domain, code: 0, userInfo: nil))
            }
            // do not call onDisconnect as it is handled in the delegate
        }

        if trace {
            NSLog("Connect: %@" + wsComponent.url!.absoluteString);
        }

        socket!.connect()
        return promise
    }

    func disconnect() {
        socket?.disconnect()
    }

    fileprivate func send<T>(proto: WebSocketEnvelope) -> Promise<T> {
        let collationID = UUID.init().uuidString
        let payload = proto.serialize(collationID: collationID)

        let (p, seal) = Promise<T>.pending()
        self.collationIDs[collationID] = (seal.fulfill, seal.reject)

        self.socket!.write(data: payload)

        return p
    }

    func send(message: Message) {
//        let binaryData = try! JSONEncoder().encode(message)
//        self.socket?.write(data: binaryData)
    }

    fileprivate  func processText(text: String){
        do{
            // 1. let's deserialize as an envelope
            let data = text.data(using: .utf8)!
            let envelope = WebSocketEnvelope.deserialize(data: data)
            if envelope.cid == nil || envelope.cid!.isEmpty {
                if envelope.error != nil {
                    self.onError!(NakamaError.missingPayload("No payload in incoming message from server: \(envelope.error?.message)"))
                } else if let msg = envelope.channelMessage {
                    self.onChannelMessage!(msg)
                } else if let msg = envelope.channelPresenceEvent {
                    self.onChannelPresence!(msg)
                } else if let msg = envelope.matchData {
                    self.onMatchData!(msg)
                } else if let msg = envelope.matchPresenceEvent {
                    self.onMatchPresence!(msg)
                } else if let msg = envelope.matchmakerMatched {
                    self.onMatchMakerMatched!(msg)
                } else if let msgs = envelope.notifications {
                    for msg in msgs.notifications {
                        self.onNotification!(msg)
                    }
                } else if let msg = envelope.statusPresenceEvent {
                    self.onStatusPresence!(msg)
                } else if let msg = envelope.streamData {
                    self.onStreamData!(msg)
                } else if let msg = envelope.streamPresenceEvent {
                    self.onStreamPresence!(msg)
                } else {
                    os_log("Unrecognised incoming uncollated message from server")
                }
            }else if let promiseTuple = self.collationIDs[envelope.cid!]{
                if let err = envelope.error {
                    let (_, reject): (fulfill: Any, reject: (Error) -> Void) = promiseTuple as! (fulfill: Any, reject: (Error) -> Void)
                    reject(NakamaError.make(from: Int32(err.code), msg: err.message))
                }
                else if let msg = envelope.rpc {
                    let (fulfill, _): (fulfill: (RpcMessage) -> Void, reject: Any) = promiseTuple as! (fulfill: (RpcMessage) -> Void, reject: Any)
                    fulfill(msg)
                }
                else if let msg = envelope.channel {
                    let (fulfill, _): (fulfill: (Channel) -> Void, reject: Any) = promiseTuple as! (fulfill: (Channel) -> Void, reject: Any)
                    fulfill(msg)
                }
                else if let msg = envelope.channelMessageAck {
                    let (fulfill, _): (fulfill: (ChannelMessageAck) -> Void, reject: Any) = promiseTuple as! (fulfill: (ChannelMessageAck) -> Void, reject: Any)
                    fulfill(msg)
                }
                else if let msg = envelope.match {
                    let (fulfill, _): (fulfill: (Match) -> Void, reject: Any) = promiseTuple as! (fulfill: (Match) -> Void, reject: Any)
                    fulfill(msg)
                }
                else if let msg = envelope.matchmakerTicket {
                    let (fulfill, _): (fulfill: (MatchmakerTicket) -> Void, reject: Any) = promiseTuple as! (fulfill: (MatchmakerTicket) -> Void, reject: Any)
                    fulfill(msg)
                }
                else if let msg = envelope.status {
                    let (fulfill, _): (fulfill: (Status) -> Void, reject: Any) = promiseTuple as! (fulfill: (Status) -> Void, reject: Any)
                    fulfill(msg)
                }
                else if let future = self.collationIDs.removeValue(forKey: envelope.cid!) {
                    let (fulfill, _): (fulfill: (() -> Void), reject: Any) = promiseTuple as! (fulfill: (() -> Void), reject: Any)
                    fulfill()
                    return
                }
            }else {
                if trace {
                    NSLog("No matching promise for incoming message: \(envelope)")
                }

            }
        }catch{
            self.onError!(NakamaError.runtimeException("Error decoding incoming message from server: \(error)"))

        }

    }


    fileprivate func process(data: Data) {
        let envelope = WebSocketEnvelope.deserialize(data: data)

        if envelope.cid == nil || envelope.cid!.isEmpty {
            if envelope.error != nil {
                self.onError!(NakamaError.missingPayload("No payload in incoming message from server"))
            } else if let msg = envelope.channelMessage {
                self.onChannelMessage!(msg)

            } else if let msg = envelope.channelPresenceEvent {
                self.onChannelPresence!(msg)
            } else if let msg = envelope.matchData {
                self.onMatchData!(msg)
            } else if let msg = envelope.matchPresenceEvent {
                self.onMatchPresence!(msg)
            } else if let msg = envelope.matchmakerMatched {
                self.onMatchMakerMatched!(msg)
            } else if let msgs = envelope.notifications {
                for msg in msgs.notifications {
                    self.onNotification!(msg)
                }

            } else if let msg = envelope.statusPresenceEvent {
                self.onStatusPresence!(msg)

            } else if let msg = envelope.streamData {
                self.onStreamData!(msg)

            } else if let msg = envelope.streamPresenceEvent {
                self.onStreamPresence!(msg)
            } else {
                os_log("Unrecognised incoming uncollated message from server")
            }

        } else if let promiseTuple = self.collationIDs[envelope.cid!] {
            if let future = self.collationIDs.removeValue(forKey: envelope.cid!) {
                let (fulfill, _): (fulfill: (() -> Void), reject: Any) = promiseTuple as! (fulfill: (() -> Void), reject: Any)
                fulfill()
                return
            }

            if let err = envelope.error {
                let (_, reject): (fulfill: Any, reject: (Error) -> Void) = promiseTuple as! (fulfill: Any, reject: (Error) -> Void)
                reject(NakamaError.make(from: Int32(err.code), msg: err.message))
            }
            if let msg = envelope.rpc {
                let (fulfill, _): (fulfill: (RpcMessage) -> Void, reject: Any) = promiseTuple as! (fulfill: (RpcMessage) -> Void, reject: Any)
                fulfill(msg)
            }

        } else {
            if trace {
                NSLog("No matching promise for incoming message: \(envelope)")
            }
        }
    }

}

//
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
import Logging
import SwiftProtobuf
import Atomics

public class WebSocketClient : SocketClient {
    public var onConnect: (() -> ())?
    
    public var onDisconnect: (() -> ())?
    
    public var onError: ((Error) -> ())?
    
    public var onChannelMessage: ((Nakama_Api_ChannelMessage) -> ())?
    
    public var onChannelPresence: ((Nakama_Realtime_ChannelPresenceEvent) -> ())?
    
    public var onMatchmakerMatched: ((Nakama_Realtime_MatchmakerMatched) -> ())?
    
    public var onMatchData: ((Nakama_Realtime_MatchData) -> ())?
    
    public var onMatchPresence: ((Nakama_Realtime_MatchPresenceEvent) -> ())?
    
    public var onNotifications: ((Nakama_Realtime_Notifications) -> ())?
    
    public var onStatusPresence: ((Nakama_Realtime_StatusPresenceEvent) -> ())?
    
    public var onStreamPresence: ((Nakama_Realtime_StreamPresenceEvent) -> ())?
    
    public var onStreamData: ((Nakama_Realtime_StreamData) -> ())?
    
    let collationCounter = ManagedAtomic<Int>(0)
    let eventLoopGroup: EventLoopGroup
    
    public let host: String
    public let port: Int
    public let ssl: Bool
    let logger : Logger?
    
    var socketAdapter: SocketAdapter
    var collatedPromises = [String:Any]()
    
    func mapEmptyVoid() -> (SwiftProtobuf.Google_Protobuf_Empty) -> EventLoopFuture<Void> {
        return { (Google_Protobuf_Empty) -> EventLoopFuture<Void> in
            return self.eventLoopGroup.next().submit { () -> Void in
                return Void()
            }
        }
    }
    
    init(host: String, port: Int, ssl: Bool, eventLoopGroup: EventLoopGroup, socketAdapter: SocketAdapter?, logger: Logger?) {
        self.host = host
        self.port = port
        self.ssl = ssl
        self.eventLoopGroup = eventLoopGroup
        self.logger = logger
        
        if socketAdapter != nil {
            self.socketAdapter = socketAdapter!
        } else {
            self.socketAdapter = WebSocketAdapter(logger: logger)
        }
        
        self.socketAdapter.onConnect = {
            self.onConnect?()
        }
        
        self.socketAdapter.onDisconnect = {
            self.onDisconnect?()
        }
        
        self.socketAdapter.onError = { error in
            self.onError?(error)
        }
        
        self.socketAdapter.onReceiveData = { data in
            self.onReceivedData(data: data)
        }
    }
    
    public func connect(session: Session) {
        self.connect(session: session, createStatus: nil)
    }
    
    public func connect(session: Session, createStatus: Bool?) {
        var components = URLComponents()
        components.scheme = self.ssl ? "wss" : "ws"
        components.host = self.host
        components.port = self.port
        components.path = "/ws"
        components.queryItems = [
            URLQueryItem(name: "token", value: session.token),
            URLQueryItem(name: "format", value: "protobuf"),
        ]
        
        if createStatus != nil {
            components.queryItems!.append(URLQueryItem(name: "status", value: createStatus! ? "true" : "false"))
        }
        
        self.socketAdapter.connect(url: components.url!)
    }
    
    public func disconnect() {
        self.socketAdapter.disconnect()
    }
    
    func send<T: SwiftProtobuf.Message>(env: inout Nakama_Realtime_Envelope) -> EventLoopFuture<T> {
        let counter = String(collationCounter.wrappingIncrementThenLoad(ordering: .relaxed))
        let promise = self.eventLoopGroup.next().makePromise(of: T.self)
        env.cid = String(counter)
        self.collatedPromises[counter] = promise
        
        let binaryData: Data = try! env.serializedData()
        self.socketAdapter.send(data: binaryData)
        return promise.futureResult
    }
    
    func onReceivedData(data: Data) {
        let response: Nakama_Realtime_Envelope
        do {
            response = try Nakama_Realtime_Envelope(serializedData: data)
            if (response.cid == "") {
                switch response.message {
                case .error(let error):
                    self.onError?(NakamaRealtimeError(error: error))
                case .channelMessage(let channelMessage):
                    self.onChannelMessage?(channelMessage)
                case .channelPresenceEvent(let channelPresenceEvent):
                    self.onChannelPresence?(channelPresenceEvent)
                case .matchData(let matchData):
                    self.onMatchData?(matchData)
                case .matchPresenceEvent(let matchPresenceEvent):
                    self.onMatchPresence?(matchPresenceEvent)
                case .matchmakerMatched(let matchermakerMatched):
                    self.onMatchmakerMatched?(matchermakerMatched)
                case .notifications(let notifications):
                    self.onNotifications?(notifications)
                case .statusPresenceEvent(let statusPresenceEvent):
                    self.onStatusPresence?(statusPresenceEvent)
                case .streamData(let streamData):
                    self.onStreamData?(streamData)
                case .streamPresenceEvent(let streamPresenceEvent):
                    self.onStreamPresence?(streamPresenceEvent)
                default:
                    self.logger?.error("Unrecognised incoming uncollated message from server: \(try! response.jsonString())")
                }
            } else {
                if let collatedPromise = self.collatedPromises[response.cid] {
                    switch response.message {
                    case .error(let error):
                        if let promise = collatedPromise as? EventLoopPromise<Nakama_Api_Rpc> {
                            promise.fail(NakamaRealtimeError(error: error))
                        } else if let promise = collatedPromise as? EventLoopPromise<Nakama_Realtime_Channel> {
                            promise.fail(NakamaRealtimeError(error: error))
                        } else if let promise = collatedPromise as? EventLoopPromise<Nakama_Realtime_ChannelMessageAck> {
                            promise.fail(NakamaRealtimeError(error: error))
                        } else if let promise = collatedPromise as? EventLoopPromise<Nakama_Realtime_Match> {
                            promise.fail(NakamaRealtimeError(error: error))
                        } else if let promise = collatedPromise as? EventLoopPromise<Nakama_Realtime_MatchmakerTicket> {
                            promise.fail(NakamaRealtimeError(error: error))
                        } else if let promise = collatedPromise as? EventLoopPromise<Nakama_Realtime_Status> {
                            promise.fail(NakamaRealtimeError(error: error))
                        }
                    case .rpc(let rpc):
                        let promise = collatedPromise as! EventLoopPromise<Nakama_Api_Rpc>
                        promise.succeed(rpc)
                    case .channel(let channel):
                        let promise = collatedPromise as! EventLoopPromise<Nakama_Realtime_Channel>
                        promise.succeed(channel)
                    case .channelMessageAck(let channelMessageAck):
                        let promise = collatedPromise as! EventLoopPromise<Nakama_Realtime_ChannelMessageAck>
                        promise.succeed(channelMessageAck)
                    case .match(let match):
                        let promise = collatedPromise as! EventLoopPromise<Nakama_Realtime_Match>
                        promise.succeed(match)
                    case .matchmakerTicket(let matchmakerTicket):
                        let promise = collatedPromise as! EventLoopPromise<Nakama_Realtime_MatchmakerTicket>
                        promise.succeed(matchmakerTicket)
                    case .status(let status):
                        let promise = collatedPromise as! EventLoopPromise<Nakama_Realtime_Status>
                        promise.succeed(status)
                    default:
                        self.logger?.error("Unrecognised incoming collated message from server: \(try! response.jsonString())")
                    }
                } else {
                    self.logger?.error("No matching promise for incoming collation ID: \(response.cid)")
                }
            }
        } catch {
            self.logger?.error("Failed to deserialise message with error: \(error)")
            self.onError?(error)
            return
        }
    }
    
    public func joinChat(target: String, type: Nakama_Realtime_ChannelJoin.TypeEnum) -> EventLoopFuture<Nakama_Realtime_Channel> {
        return self.joinChat(target: target, type: type, persistence: nil, hidden: nil)
    }
    
    public func joinChat(target: String, type: Nakama_Realtime_ChannelJoin.TypeEnum, persistence: Bool?, hidden: Bool?) -> EventLoopFuture<Nakama_Realtime_Channel> {
        var req = Nakama_Realtime_ChannelJoin()
        req.target = target
        req.type = Int32(type.rawValue)
        req.hidden = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.hidden.value = hidden ?? hidden!
        req.persistence = SwiftProtobuf.Google_Protobuf_BoolValue()
        req.persistence.value = persistence ?? persistence!
        
        var env = Nakama_Realtime_Envelope()
        env.channelJoin = req
        
        return self.send(env: &env)
    }
    
    public func leaveChat(channelId: String) -> EventLoopFuture<Void> {
        var req = Nakama_Realtime_ChannelLeave()
        req.channelID = channelId
        
        var env = Nakama_Realtime_Envelope()
        env.channelLeave = req
        
        let resp: EventLoopFuture<SwiftProtobuf.Google_Protobuf_Empty> = self.send(env: &env)
        return resp.flatMap(mapEmptyVoid())
    }
    
    public func removeChatMessage(channelId: String, messageId: String) -> EventLoopFuture<Nakama_Realtime_ChannelMessageAck> {
        var req = Nakama_Realtime_ChannelMessageRemove()
        req.channelID = channelId
        req.messageID = messageId
        
        var env = Nakama_Realtime_Envelope()
        env.channelMessageRemove = req
        
        return self.send(env: &env)
    }
    
    public func writeChatMessage(channelId: String, content: String) -> EventLoopFuture<Nakama_Realtime_ChannelMessageAck> {
        var req = Nakama_Realtime_ChannelMessageSend()
        req.channelID = channelId
        req.content = content
        var env = Nakama_Realtime_Envelope()
        env.channelMessageSend = req
        
        return self.send(env: &env)
    }
    
    public func updateChatMessage(channelId: String, messageId: String, content: String) -> EventLoopFuture<Nakama_Realtime_ChannelMessageAck> {
        var req = Nakama_Realtime_ChannelMessageUpdate()
        req.channelID = channelId
        req.messageID = messageId
        req.content = content
        var env = Nakama_Realtime_Envelope()
        env.channelMessageUpdate = req
        
        return self.send(env: &env)
    }

    public func createMatch() -> EventLoopFuture<Nakama_Realtime_Match> {
        var env = Nakama_Realtime_Envelope()
        env.matchCreate = Nakama_Realtime_MatchCreate()
        
        return self.send(env: &env)
    }

    public func joinMatch(matchId: String) -> EventLoopFuture<Nakama_Realtime_Match> {
        self.joinMatch(matchId: matchId, metadata: nil)
    }
    
    public func joinMatch(matchId: String, metadata: [String : String]?) -> EventLoopFuture<Nakama_Realtime_Match> {
        var req = Nakama_Realtime_MatchJoin()
        req.matchID = matchId
        if metadata != nil {
            req.metadata = metadata!
        }
        var env = Nakama_Realtime_Envelope()
        env.matchJoin = req
        
        return self.send(env: &env)
    }

    public func joinMatchToken(token: String) -> EventLoopFuture<Nakama_Realtime_Match> {
        var req = Nakama_Realtime_MatchJoin()
        req.token = token
        var env = Nakama_Realtime_Envelope()
        env.matchJoin = req
        
        return self.send(env: &env)
    }

    public func leaveMatch(matchId: String) -> EventLoopFuture<Void> {
        var req = Nakama_Realtime_MatchLeave()
        req.matchID = matchId
        
        var env = Nakama_Realtime_Envelope()
        env.matchLeave = req
        
        let resp: EventLoopFuture<SwiftProtobuf.Google_Protobuf_Empty> = self.send(env: &env)
        return resp.flatMap(mapEmptyVoid())
    }
    
    public func addMatchmaker(minCount: Int32) -> EventLoopFuture<Nakama_Realtime_MatchmakerTicket> {
        return self.addMatchmaker(minCount: minCount, maxCount: nil, query: nil, stringProperties: nil, numericProperties: nil)
    }
    
    public func addMatchmaker(minCount: Int32, maxCount: Int32?) -> EventLoopFuture<Nakama_Realtime_MatchmakerTicket> {
        return self.addMatchmaker(minCount: minCount, maxCount: maxCount, query: nil, stringProperties: nil, numericProperties: nil)
    }
    
    public func addMatchmaker(minCount: Int32, maxCount: Int32?, query: String?) -> EventLoopFuture<Nakama_Realtime_MatchmakerTicket> {
        return self.addMatchmaker(minCount: minCount, maxCount: maxCount, query: query, stringProperties: nil, numericProperties: nil)
    }

    public func addMatchmaker(minCount: Int32, maxCount: Int32?, query: String?, stringProperties: [String : String]?, numericProperties: [String : Double]?) -> EventLoopFuture<Nakama_Realtime_MatchmakerTicket> {
        var req = Nakama_Realtime_MatchmakerAdd()
        req.minCount = minCount
        if maxCount != nil {
            req.maxCount = maxCount!
        }
        if query != nil {
            req.query = query!
        }
        if stringProperties != nil {
            req.stringProperties = stringProperties!
        }
        if numericProperties != nil {
            req.numericProperties = numericProperties!
        }
        var env = Nakama_Realtime_Envelope()
        env.matchmakerAdd = req
        
        return self.send(env: &env)
    }

    public func removeMatchmaker(ticket: String) -> EventLoopFuture<Void> {
        var req = Nakama_Realtime_MatchmakerRemove()
        req.ticket = ticket
        
        var env = Nakama_Realtime_Envelope()
        env.matchmakerRemove = req
        
        let resp: EventLoopFuture<SwiftProtobuf.Google_Protobuf_Empty> = self.send(env: &env)
        return resp.flatMap(mapEmptyVoid())
    }

    public func sendMatchData(matchId: String, opCode: Int64, data: Data, presences: [Nakama_Realtime_UserPresence]?) {
        var req = Nakama_Realtime_MatchDataSend()
        req.matchID = matchId
        req.opCode = opCode
        req.data = data
        if presences != nil {
            req.presences = presences!
        }
        
        var env = Nakama_Realtime_Envelope()
        env.matchDataSend = req
        
        let binaryData: Data = try! env.serializedData()
        self.socketAdapter.send(data: binaryData)
    }

    public func rpc(id: String, payload: String?) -> EventLoopFuture<Nakama_Api_Rpc> {
        var req = Nakama_Api_Rpc()
        req.id = id
        if payload != nil {
            req.payload = payload!
        }
        
        var env = Nakama_Realtime_Envelope()
        env.rpc = req
        
        return send(env: &env)
    }

    public func followUsers(userIds: String...) -> EventLoopFuture<Nakama_Realtime_Status> {
        return self.followUsers(userIds: userIds, usernames: nil)
    }
    
    public func followUsers(userIds: [String]?, usernames: [String]?) -> EventLoopFuture<Nakama_Realtime_Status> {
        var req = Nakama_Realtime_StatusFollow()
        if userIds != nil {
            req.userIds = userIds!
        }
        if usernames != nil {
            req.usernames = usernames!
        }
        
        var env = Nakama_Realtime_Envelope()
        env.statusFollow = req
        
        return send(env: &env)
    }

    public func unfollowUsers(userIds: String...) -> EventLoopFuture<Void> {
        var req = Nakama_Realtime_StatusUnfollow()
        req.userIds = userIds
        
        var env = Nakama_Realtime_Envelope()
        env.statusUnfollow = req
        
        let resp: EventLoopFuture<SwiftProtobuf.Google_Protobuf_Empty> = self.send(env: &env)
        return resp.flatMap(mapEmptyVoid())
    }

    public func updateStatus(status: String?) -> EventLoopFuture<Void> {
        var req = Nakama_Realtime_StatusUpdate()
        req.status = SwiftProtobuf.Google_Protobuf_StringValue()
        if status != nil {
            req.status.value = status!
        }
        
        var env = Nakama_Realtime_Envelope()
        env.statusUpdate = req
        
        let resp: EventLoopFuture<SwiftProtobuf.Google_Protobuf_Empty> = self.send(env: &env)
        return resp.flatMap(mapEmptyVoid())
    }
}

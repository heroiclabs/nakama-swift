/*
 * Copyright 2017 Heroic Labs
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
import PromiseKit
import Starscream
import SwiftProtobuf

/**
   A message which requires no acknowledgement by the server.
 */
public protocol Message : CustomStringConvertible {
  /**
   - Returns: The serialized format of the message.
   */
  func serialize() -> Data?
}

/**
   A message which returns a response from the server.
 
   - Parameter <T>: The type of the message response.
 */
public protocol CollatedMessage : CustomStringConvertible {
  
  /**
     - Parameter collationId: The collation ID to assign to the serialized message instance.
     - Returns: The serialized format of the message.
   */
  func serialize(collationID: String) -> Data?
}

public class Builder {
  private let serverKey : String
  private var host : String = "127.0.0.1"
  private var port : Int = 7350
  private var lang : String = "en"
  private var ssl : Bool = false
  private var timeout : Int = 5000
  private var trace : Bool = false
  
  init(serverKey: String) {
    self.serverKey = serverKey
  }
  
  public func build() -> Client {
    return DefaultClient(serverKey: serverKey, host: host, port: port, lang: lang, ssl: ssl, timeout: timeout, trace: trace)
  }
  
  public func host(host: String) -> Builder {
    self.host = host
    return self
  }
  
  public func port(port: Int) -> Builder {
    self.port = port
    return self
  }
  
  public func lang(lang: String) -> Builder {
    self.lang = lang
    return self
  }
  
  public func ssl(ssl: Bool) -> Builder {
    self.ssl = ssl
    return self
  }
  
  public func timeout(timeout: Int) -> Builder {
    self.timeout = timeout
    return self
  }
  
  public func trace(trace: Bool) -> Builder {
    self.trace = trace
    return self
  }
  
  public class func defaults(serverKey : String) -> Client {
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
   - Parameter message : message The {@code AuthenticateMessage} to send to the server.
   - Returns: A {@code Session} for the user.
   */
  func login(with message: AuthenticateMessage) -> Promise<Session>
  
  /**
   - Parameter message : message The {@code AuthenticateMessage} to send to the server.
   - Returns: A {@code Session} for the user.
   */
  func register(with message: AuthenticateMessage) -> Promise<Session>
  
  /**
   - Parameter session : session The {@code Session} to connect the socket with.
   - Returns: Placeholder return type to allow chaining operations.
   */
  func connect(to session: Session) -> Promise<Session>
  
  /**
   - Sends a disconnect request to the server. When disconnected, `onDisconnect` is invoked.
   */
  func disconnect()
  
  /**
   - Send a logout request to the server
   */
  func logout()
  
  /**
   - Parameter message : message The message to send.
   - Parameter <T>: The expected return type.
   - Returns: An instance of the expected return type.
   */
  func send(message: UsersFetchMessage) -> Promise<[User]>
  func send(message: SelfFetchMessage) -> Promise<SelfUser>
  func send(message: SelfUpdateMessage) -> Promise<Void>
  func send(message: SelfLinkMessage) -> Promise<Void>
  func send(message: SelfUnlinkMessage) -> Promise<Void>
  func send(message: RPCMessage) -> Promise<RPCResult>
  func send(message: StorageFetchMessage) -> Promise<[StorageRecord]>
  func send(message: StorageListMessage) -> Promise<[StorageRecord]>
  func send(message: StorageRemoveMessage) -> Promise<Void>
  func send(message: StorageWriteMessage) -> Promise<[StorageRecordID]>
  func send(message: StorageUpdateMessage) -> Promise<[StorageRecordID]>
  
  /**
   - Parameter message : message The message to send.
   */
  func send(message: Message)
}

internal class DefaultClient : Client, WebSocketDelegate {
  private let serverKey: String
  private let lang: String
  private let timeout: Int
  private let trace: Bool
  
  private let loginUrl: URL
  private let registerUrl: URL
  
  private var wsComponent: URLComponents
  private var socket : WebSocket?
  private var collationIDs = [String: Any]()
  private var _serverTime : Int = 0
  
  var onDisconnect: ((Error?) -> Void)?
  var onError: ((NakamaError) -> Void)?
  var serverTime: Int {
    return self._serverTime != 0 ? self._serverTime : Int(Date().timeIntervalSince1970 * 1000.0);
  }
  
  internal init(serverKey: String, host: String, port: Int, lang: String,
                ssl: Bool, timeout: Int, trace: Bool) {
    
    self.serverKey = serverKey
    self.lang = lang
    self.timeout = timeout
    self.trace = trace
    
    var urlComponent = URLComponents()
    urlComponent.host = host
    urlComponent.port = port
    urlComponent.scheme = ssl ? "https" : "http"
    
    urlComponent.path = "/user/login"
    self.loginUrl = urlComponent.url!
    
    urlComponent.path = "/user/register"
    self.registerUrl = urlComponent.url!
    
    self.wsComponent = URLComponents()
    self.wsComponent.host = host
    self.wsComponent.port = port
    self.wsComponent.scheme = ssl ? "wss" : "ws"
    self.wsComponent.path = "/api"
  }
  
  func websocketDidConnect(socket: WebSocket) {}
  
  func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
    self.collationIDs.removeAll()
    if self.onDisconnect != nil {
      self.onDisconnect!(error)
    }
  }
  
  func websocketDidReceiveMessage(socket: WebSocket, text: String) {
    if trace {
      NSLog("Unexpected string message from server: %@", text);
    }
  }
  
  func websocketDidReceiveData(socket: WebSocket, data: Data) {
    process(data: data)
  }
  
  func register(with message: AuthenticateMessage) -> Promise<Session> {
    return self.authenticate(path: registerUrl, message: message)
  }
  
  func login(with message: AuthenticateMessage) -> Promise<Session> {
    return self.authenticate(path: loginUrl, message: message)
  }
  
  fileprivate func authenticate(path: URL, message: AuthenticateMessage) -> Promise<Session> {
    var request = URLRequest(url: path)
    request.httpMethod = "POST"
    request.httpBody = message.serialize()
    
    let basicAuth = serverKey + ":"
    let authValue = "Basic " + basicAuth.data(using: .utf8)!.base64EncodedString()
    request.addValue(authValue, forHTTPHeaderField: "Authorization")
    request.addValue(lang, forHTTPHeaderField: "Accept-Language")
    
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = TimeInterval(timeout)
    configuration.timeoutIntervalForResource = TimeInterval(timeout)
    configuration.allowsCellularAccess = true
    let session = URLSession(configuration: configuration)
    
    if trace {
      NSLog("Authenticate request: %@", message.description)
    }
    
    let (p, fulfill, reject) = Promise<Session>.pending()
    session.dataTask(with: request, completionHandler: { (data: Data?, rsp: URLResponse?, error: Error?) in
      
      // Connectivity issues
      guard error == nil else {
        if self.trace {
          NSLog("Authentication error: %@", error!.localizedDescription)
        }
        reject(error!)
        return
      }
      
      if let rsp = rsp as? HTTPURLResponse, rsp.statusCode >= 500 {
        reject(NakamaError.runtimeException(String(format:"Internal Server Error - HTTP %@", rsp.statusCode)))
        return
      }
      
      let authResponse = try! Server_AuthenticateResponse(serializedData: data!)
      if self.trace {
        NSLog("Authenticate response: %@", authResponse.debugDescription);
      }
      
      switch authResponse.id! {
      case .error(let err):
        reject(NakamaError.make(from: err.code, msg: err.message))
      case .session(let s):
        fulfill(DefaultSession(token: s.token))
      }
    }).resume()
    return p
  }
  
  func connect(to session: Session) -> Promise<Session> {
    if (socket != nil) {
      precondition(socket!.isConnected, "socket is already connected")
    }
    
    let (p, fulfill, reject) = Promise<Session>.pending()
    
    wsComponent.queryItems = [
      URLQueryItem.init(name: "token", value: session.token),
      URLQueryItem.init(name: "lang", value: lang)
    ]
    
    socket = WebSocket(url: wsComponent.url!)
    socket!.httpMethod = WebSocket.HTTPMethod.get
    socket!.delegate = self
    socket!.enableCompression = true
    socket!.timeout = timeout
    socket!.onConnect = {
      if p.isPending {
        fulfill(session)
      }
    }
    socket!.onDisconnect = { error in
      if p.isPending {
        reject(error ?? NSError(domain:NakamaError.Domain, code:0, userInfo:nil))
      }
      // do not call onDisconnect as it is handled in the delegate
    }
    
    if trace {
      NSLog("Connect: %@" + wsComponent.url!.absoluteString);
    }
    
    socket!.connect()
    return p
  }

  func disconnect() {
    socket?.disconnect()
  }

  func logout() {
    self.send(message: LogoutMessage.init())
  }
  
  fileprivate func send<T>(proto message: CollatedMessage) -> Promise<T> {
    let collationID = UUID.init().uuidString
    let payload = message.serialize(collationID: collationID)
    
    let p  = Promise<T>.pending()
    self.collationIDs[collationID] = (p.fulfill, p.reject)

    self.socket!.write(data: payload!)

    return p.promise
  }
  
  func send(message: Message) {
    let binaryData = message.serialize()!
    self.socket?.write(data: binaryData)
  }
  
  func send(message: UsersFetchMessage) -> Promise<[User]> {
    return self.send(proto: message)
  }
  
  func send(message: SelfFetchMessage) -> Promise<SelfUser> {
    return self.send(proto: message)
  }
  
  func send(message: SelfUpdateMessage) -> Promise<Void> {
    return self.send(proto: message)
  }
  
  func send(message: SelfLinkMessage) -> Promise<Void> {
    return self.send(proto: message)
  }
  
  func send(message: SelfUnlinkMessage) -> Promise<Void> {
    return self.send(proto: message)
  }
  
  func send(message: RPCMessage) -> Promise<RPCResult> {
    return self.send(proto: message)
  }
  
  
  func send(message: StorageFetchMessage) -> Promise<[StorageRecord]> {
    return self.send(proto: message)
  }
  
  func send(message: StorageListMessage) -> Promise<[StorageRecord]> {
    return self.send(proto: message)
  }
  
  func send(message: StorageRemoveMessage) -> Promise<Void> {
    return self.send(proto: message)
  }
  
  func send(message: StorageWriteMessage) -> Promise<[StorageRecordID]> {
    return self.send(proto: message)
  }
  
  func send(message: StorageUpdateMessage) -> Promise<[StorageRecordID]> {
    return self.send(proto: message)
  }
  
  fileprivate func process(data: Data) {
    let envelope = try! Server_Envelope(serializedData: data)
    
    if envelope.collationID.isEmpty {
      switch envelope.payload! {
      case .heartbeat(let heartbeat):
        let newServerTime = Int(heartbeat.timestamp)
        if (newServerTime > self._serverTime) {
          self._serverTime = newServerTime;
        }
      default:
        NSLog("No payload for incoming uncollated message from the server: %@", (try? envelope.jsonString()) ?? "nil");
      }
      
      if self.onError != nil {
        self.onError!(NakamaError.missingPayload("No payload in incoming message from server"))
      }
      
    } else if let promiseTuple = self.collationIDs[envelope.collationID] {
      self.collationIDs.removeValue(forKey: envelope.collationID)
      
      if envelope.payload == nil {
        let (fulfill, _) : (fulfill: (() -> Void), reject: Any) = promiseTuple as! (fulfill: (() -> Void), reject: Any)
        fulfill()
        return
      }
      
      switch envelope.payload! {
      case .error(let err):
        let (_, reject) : (fulfill: Any, reject: (Error) -> Void) = promiseTuple as! (fulfill: Any, reject: (Error) -> Void)
        reject(NakamaError.make(from: err.code, msg: err.message))
      case .self_p(let proto):
        let (fulfill, _) : (fulfill: (SelfUser) -> Void, reject: Any) = promiseTuple as! (fulfill: (SelfUser) -> Void, reject: Any)
        fulfill(DefaultSelf(from: proto))
      case .users(let proto):
        let (fulfill, _) : (fulfill: ([User]) -> Void, reject: Any) = promiseTuple as! (fulfill: ([User]) -> Void, reject: Any)
        var users : [User] = []
        for user in proto.users {
          users.append(DefaultUser(from: user))
        }
        fulfill(users)
      case .rpc(let proto):
        let (fulfill, _) : (fulfill: (RPCResult) -> Void, reject: Any) = promiseTuple as! (fulfill: (RPCResult) -> Void, reject: Any)
        fulfill(DefaultRPCResult(from: proto))
      case .storageKeys(let proto):
        let (fulfill, _) : (fulfill: ([StorageRecordID]) -> Void, reject: Any) = promiseTuple as! (fulfill: ([StorageRecordID]) -> Void, reject: Any)
        var records : [StorageRecordID] = []
        for key in proto.keys {
          records.append(DefaultStorageRecordID(from: key))
        }
        fulfill(records)
      case .storageData(let proto):
        let (fulfill, _) : (fulfill: ([StorageRecord]) -> Void, reject: Any) = promiseTuple as! (fulfill: ([StorageRecord]) -> Void, reject: Any)
        var records : [StorageRecord] = []
        records._cursor = proto.cursor
        for data in proto.data {
          records.append(DefaultStorageRecord(from: data))
        }
        fulfill(records)
        
      default:
        if trace {
          NSLog("No client behaviour for incoming message: %@", (try? envelope.jsonString()) ?? "nil");
        }
      }
    } else {
      if trace {
        NSLog("No matching promise for incoming message: %@", (try? envelope.jsonString()) ?? "nil");
      }
    }
  }
}

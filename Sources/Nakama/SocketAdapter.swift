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

public protocol SocketAdapter {
    /**
     If set, notifies when the socket was connected.
     */
    var onConnect: (()->())? {get set}
    /**
     If set, notifies when socket was disconnected.
     */
    var onDisconnect: (() -> ())? {get set}
    /**
     If set, notifies when new binary data was received.
     */
    var onReceiveData: ((Data) -> ())? {get set}
    /**
     If set, notified when new text data was received.
     */
    var onReceiveText: ((String) -> ())? {get set}
    /**
     If set, notifies when a connection error has occured.
     */
    var onError: ((Error) -> ())? {get set}
    
    /**
     Connect to the given URL.
     - Parameter url: The URL to connect to.
     */
    func connect(url: URL)
    /**
     Disconnect from the socket.
     */
    func disconnect()
    /**
     Send data to the open socket.
     - Parameter data: Data to be sent down the socket.
     */
    func send(data: Data)
}

public class WebSocketAdapter: NSObject, URLSessionWebSocketDelegate, SocketAdapter {
    public var onConnect: (() -> ())?
    public var onDisconnect: (() -> ())?
    public var onReceiveText: ((String) -> ())?
    public var onReceiveData: ((Data) -> ())?
    public var onError: ((Error) -> ())?
    
    let logger : Logger?
    var wsTask: URLSessionWebSocketTask?
    
    init(logger: Logger?) {
        self.logger = logger
    }
    
    public func connect(url: URL) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        self.wsTask = session.webSocketTask(with: url)
        self.wsTask!.resume()
    }
    
    public func disconnect() {
        self.wsTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func ping() {
        if self.wsTask?.state != .running {
            return
        }
        
        self.wsTask?.sendPing { error in
        if let error = error {
            self.logger?.error("Couldn't send ping message: \(error)")
            // TODO handle error
        } else {
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                self.ping()
            }
        }
      }
    }
    
    func receive() {
        // try to receive is completed (cancelled) or is canceling then ignore
        if self.wsTask?.state == .completed || self.wsTask?.state == .canceling {
            return
        }
        
        self.wsTask?.receive { result in
        switch result {
        case .success(let message):
          switch message {
          case .data(let data):
            self.onReceiveData?(data)
          case .string(let text):
            self.onReceiveText?(text)
          default:
            self.logger?.warning("Received unknown message.")
          }
        case .failure(let error):
            self.onError?(error)
            self.logger?.error("WebSocketClient logger received error: \(error)")
        }
        
        self.receive()
      }
    }
    
    public func send(data: Data) {
        self.wsTask?.send(.data(data)) { (error: Error?) in
            if (error != nil) {
                self.logger?.error("Failed to send message with error: \(error!)")
                self.onError?(error!)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        logger?.debug("Socket connection opened successfully.")
        self.onConnect?()
        self.receive()
        self.ping()
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.logger?.debug("Socket connection closed - code: \(closeCode) - reason: \(String(describing: reason))")
        self.onDisconnect?()
    }
}


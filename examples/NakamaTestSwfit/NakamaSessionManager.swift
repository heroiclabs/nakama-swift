//
//  NakamaSessionManager.swift
//  NakamaExampleApp
//
//  Created by Allan Nava on 07/04/2021.
//  Updated by Allan Nava on 07/04/2021.
//

import Nakama
import PromiseKit

public class NakamaSessionManager {
    let client: Client;
    private var session : Session?
        
    private static let defaults = UserDefaults.standard
    private static let deviceKey = "device_id"
    private static let sessionKey = "session"

    static let nakama_host  = "127.0.0.1"
    static let nakama_port  = 7350
    static let nakama_ssl   = true
    //
    init() {
        client = Builder(serverKey: "defaultkey")
                    .host( NakamaSessionManager.nakama_host )
                    .port( NakamaSessionManager.nakama_port )
                    .ssl( NakamaSessionManager.nakama_ssl )
                    .build()
        //
        self.startV2()
    }
    
    func startV2()
    {
        let email = "super@heroes.com";
        let password = "batsignal";
        //client.
        /*client.authenticateEmail( email: email, password: password, create: true ).then { [weak self] session -> Promise<Session> in
            
        }*/
        print("startV2")
        client.authenticateEmail( email: email, password: password, create : true )
        //
    }
    
    func start() {
        restoreSessionAndConnect()
        if session == nil {
            loginOrRegister()
        }
    }
    
    
    private func restoreSessionAndConnect() {
        // Lets check if we can restore a cached session
        let sessionString : String? = NakamaSessionManager.defaults.string(forKey: NakamaSessionManager.sessionKey)
        if sessionString == nil {
            return
        }
        let session = DefaultSession.restore(token: sessionString!)
        if session.isExpired(currentTimeSince1970: Date().timeIntervalSince1970) {
            return
        }

        connect(with: session)
    }
    
    private func loginOrRegister() {
        var deviceId : String? = NakamaSessionManager.defaults.string(forKey: NakamaSessionManager.deviceKey)
        if deviceId == nil {
            deviceId = UIDevice.current.identifierForVendor!.uuidString
            NakamaSessionManager.defaults.set(deviceId!, forKey: NakamaSessionManager.deviceKey)
        }

        /*let message = AuthenticateMessage(device: deviceId!)
        client.login(with: message).then { session in
            NakamaSessionManager.defaults.set(session.token, forKey: NakamaSessionManager.sessionKey)
            self.connect(with: session)
            }.catch{ err in
            if (err is NakamaError) {
                switch err as! NakamaError {
                case .userNotFound(_):
                self.client.register(with: message).then { session in
                    self.connect(with: session)
                    }.catch{ err in
                    print("Could not register: %@", err)
                }
                return
                default:
                break
                }
            }
            print("Could not login: %@", err)
        }*/
    }


    private func connect(with session: Session) {
        /*self.client.createSocket(to: session).then { (Session) -> rsp; in
            //Session
            //self.session =
            self.session =  rsp.session
            NakamaSessionManager.defaults.set(session.token, forKey: NakamaSessionManager.sessionKey)
        }*/
        /*client.connect(to: session).then { _ in
            self.session = session

            // Store session for quick reconnects.
            NakamaSessionManager.defaults.set(session.token, forKey: NakamaSessionManager.sessionKey)
            }.catch{ err in
            print("Failed to connect to server: %@", err)
        }*/
    }
    
}

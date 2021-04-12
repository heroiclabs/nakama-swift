//
//  NakamaSessionManager.swift
//  NakamaExampleApp
//
//  Created by Allan Nava on 07/04/2021.
//  Updated by Allan Nava on 12/04/2021.
//

import Nakama

public class NakamaSessionManager {
    var client: Client;
    //private var session : Session?
        
    private static let defaults = UserDefaults.standard
    private static let deviceKey = "device_id"
    private static let sessionKey = "session"

    static let nakama_host  = "127.0.0.1"
    static let nakama_port  = 7350
    static let nakama_ssl   = true
    //
    init() {
        client = GrpcClient(serverKey: "defaultkey", host: NakamaSessionManager.nakama_host, port: NakamaSessionManager.nakama_port, ssl: NakamaSessionManager.nakama_ssl, trace: true )
        //
    }
    
    func connectWithEmail(email: String, password: String){
        print("connectWithEmail")
        let email = "super@heroes.com";
        let password = "batsignal";
        let session = try! client.authenticateEmail(email: email, password: password, create: true).wait();
        print(session.token);
        
    }
    
}

Nakama Swift
============

> Swift client for Nakama server.

[Nakama](https://github.com/heroiclabs/nakama) is an open-source server designed to power modern games and apps. Features include user accounts, chat, social, matchmaker, realtime multiplayer, and much [more](https://heroiclabs.com).

This client implements the protocol and all features available in the server. It is compatible with Swift 5.3+.


## Getting Started

You'll need to setup the server and database before you can connect with the client. The simplest way is to use Docker but have a look at the [server documentation](https://github.com/heroiclabs/nakama#getting-started) for other options.

1. Install and run the servers. Follow these [instructions](https://heroiclabs.com/docs/install-docker-quickstart).

2. You can use the Swift package manager to add the code as a dependency for your project. Add the client as a dependency to your "Package.swift" file.

```swift
let package = Package(
  // ...
  dependencies: [
    .Package(url: "https://github.com/heroiclabs/nakama-swift.git", Version(3,0,0)),
  ]
)
```

We have a guide which covers how to use the client with lots of code examples:

https://heroiclabs.com/docs/swift-ios-client-guide/

3. Use the connection credentials to build a client object.

To create a client which can connect to the Nakama server with the default settings.

```swift
import Nakama

public class NakamaSessionManager {
  private let client: Client;

  init() {
    let host = "127.0.0.1"
    let port = 7349
    let serverKey = "defaultkey"
    let ssl = false
    client = GrpcClient(serverKey: "defaultkey", host: host, port: port, ssl: ssl)
  }
}
```

### Authenticate

There's a variety of ways to [authenticate](https://heroiclabs.com/docs/authentication) with the server. Authentication can create a user if they don't already exist with those credentials. It's also easy to authenticate with a social profile from Google Play Games, Facebook, Game Center, etc.

```swift
let email = "super@heroes.com";
let password = "batsignal";
let session = try! client.AuthenticateEmail(email, password).wait();
print(session.token);
```

### Sessions

When authenticated the server responds with an auth token (JWT) which contains useful properties and gets deserialized into a `Session` object.

```swift
print(session.token) // raw JWT token
print(session.userId)
print(session.username)
print("Session has expired: \(session.expired)")
print("Session expires at: \(session.expiryTime)")
```

It is recommended to store the auth token from the session and check at startup if it has expired. If the token has expired you must reauthenticate. The expiry time of the token can be changed as a setting in the server.

```swift
let authtoken = "restored from somewhere"
let session = DefaultSession.restore(authtoken)
if (session.expired)
{
    print("Session has expired. Must reauthenticate!")
}
```

NOTE: The length of the lifetime of a session can be changed on the server with the "--session.token_expiry_sec" command flag argument.

### Requests

The client includes lots of builtin APIs for various features of the game server. These can be accessed with the async methods. It can also call custom logic in RPC functions on the server. These can also be executed with a socket object.

All requests are sent with a session object which authorizes the client.

```swift
let account = try! client.GetAccount(session).wait()
print(account.user.id)
print(account.user.username)
print(account.user.wallet)
```

### Socket

The client can create one or more sockets with the server. Each socket can have it's own event listeners registered for responses received from the server.

```swift
let host = "127.0.0.1"
let port = 7350
let ssl = false

var socket = client.createSocket(host: host, port: port, ssl: ssl)
socket.onConnect = {
    print("Socket connected!")
}
socket.onDisconnect = {
    print("Socket disconnected!")
}
socket.onError = { error in
    self.logger.error("Socket received error: \(error)")
}
socket.connect(session: session)
```

## Contribute

To build the codebase you will need to install these dependencies:

* Swift 5.3+
* XCode 12.3+

You must clone the repository and can (optionally) generate updated protocol buffers definitions if needed.

```shell
$> git clone git@github.com:heroiclabs/nakama-swift.git
$> swift package fetch
```

### Development

With the codebase setup you can build and test.

```shell
$> swift build
$> swift test
```

### License

This project is licensed under the [Apache-2 License](https://github.com/heroiclabs/nakama-swift/blob/master/LICENSE).

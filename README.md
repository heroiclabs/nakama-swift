Nakama Swift
============

Nakama is an open-source server designed to power modern games and apps. Features include user accounts, chat, social, matchmaker, realtime multiplayer, and much more.

This client is written in swift and supports Nakama v3 API and socket features. Most apple platforms are supported including: iOS, macOS, iPadOS, tvOS and visionOS.

The client is implemented using swift concurrency with async/await for asynchronously calling client and socket methods.

**Minimum supported swift version is 5.6**

## Getting Started

You need to use Swift Package Manager (SPM) for integrating the sdk into your project.
Add nakama-swift as a dependency to your **Package.swift** or using Xcode project **Package Dependencies** settings.

**Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/heroiclabs/nakama-swift.git", .upToNextMajor(from: "1.0.0"))
]
```
After the package is installed, build the client object using connection credentials:
```swift
let client = GrpcClient(
    serverKey: "defaultkey",
    host: "127.0.0.1",
    ssl: false
)
```

## Usage

The client object has many methods to execute various features in the server or open realtime socket connections with the server.

## Authenticate

There's a variety of ways to authenticate with the server. Authentication can create a user if they don't already exist with those credentials. It's also easy to authenticate with a social profile from Google Play Games, Facebook, Apple, Game Center, etc.

```swift
do {
    let email = "abc@xyz.com";
    let password = "p4ssword";
    var session = try await client.authenticateEmail(email: email, password: password)
    print(session.userId);
} catch {
    debugPrint(error)
}
```
async request needs to be included inside a do-catch statement to handle throwing errors, it will be ommitted in next examples for simplicity.

## Sessions

When authenticated the server responds with an auth token (JWT) which contains useful properties and gets deserialized into a Session object.
```swift
print(session.token) // Raw JWT token
print(session.userId) // User ID
print(session.username) // Username
print(session.isExpired) // Boolean status
print(session.expiryTime) // As Date object
```
It is recommended to store the auth token from the session and check at App startup if it has expired. If the token has expired you must re-authenticate. The expiry time of the token can be changed as in server settings configuration.

```swift
if session.hasExpired(offset: Date().addingTimeInterval(5 * 60)) { // Session about to expire in 5 minutes
    do {
        session = try await client.refreshSession(session: session)
    } catch {
        print("Session can no longer be refreshed. Must reauthenticate!");
    }
}
```

⚠️ NOTE: The length of the lifetime of a session can be set on the server with the "--session.token_expiry_sec" command flag argument. The lifetime of the refresh token for a session can be set on the server with the "--session.refresh_token_expiry_sec" command flag.

## Requests

The client includes a lot of builtin APIs for various features of the game server. These can be accessed with the async methods. It can also call custom logic in RPC functions on the server. RPCs can also be executed with a socket object.

All requests are sent with a session object which authorizes the client.
```swift
var account = try await client.getAccount(session: session)
print(account.user.id)
print(account.user.username)
print(account.wallet)
```

Requests can be supplied with a retry configurations in cases of transient network or server errors.

A single configuration can be used as a global configuration in the client to control all request-retry behavior:
```swift
var retryConfiguration = RetryConfiguration(baseDelayMs: 1000, maxRetries: 5,retryListener: { retries, retry in
    print("about to retry...")
})

client.GlobalRetryConfiguration = retryConfiguration;
var account = await client.GetAccountAsync(session);
```
Or, the configuration can be supplied on a per-request basis:
```swift
var retryConfiguration = RetryConfiguration(baseDelayMs: 1000, maxRetries: 5,retryListener: { retries, retry in
    print("about to retry...")
})
client.globalRetryConfiguration = retryConfiguration;
var account = try await client.getAccount(session: session)
```
Per-request retry configurations override the global retry configuration.

## Socket

The client can create one or more sockets to interact with the server.
Socket can be created from the client using no parameters or providing ones:
```swift
var socket = client.createSocket(host: "127.0.0.1", port: 7350, ssl: false) as! Socket
```
Notice we did a cast in createSocket() because it returns a SocketProtocol type, but we want a `Socket` type in order to access the Socket implementation methods not the protocol ones.

 Each socket can have it's own event listeners registered for responses received from the server.
```swift
socket.onConnect = {
    print("Socket connected.")
}
socket.onDisconnect = {
    print("Socket disconnected.")
}
socket.onError = { error in
    debugPrint(error)
}
try await socket.connect(session: session)
```
After we finish from the socket we need to disconnect it
```swift
socket.disconnect()
```

# Satori

Satori is a liveops server for games that powers actionable analytics, A/B testing and remote configuration. Use the Satori Swift Client to communicate with Satori from within your Swift game.

Full documentation is online - https://heroiclabs.com/docs/satori/client-libraries/swift/index.html

## Getting Started

Create a client object that accepts the API key you were given as a Satori customer.

```swift
import Satori

let scheme = "http"
let host = "127.0.0.1"
let port: Int = 7450
let apiKey = "apiKey"

let client = HttpClient(scheme: scheme, host: host, port: port, apiKey: apiKey)
```

Then authenticate with the server to obtain your session:

```swift
do {
    session = try await client.authenticate(id: "your-id")
    debugPrint("Authenticated successfully.")
} catch {
    debugPrint("Error authenticating: \(error.localizedDescription)")
}
```

Using the client you can get any experiments or feature flags the user belongs to:

```swift
let experiments = try await client.getExperiments(session: session, names: ["experiment1", "Experiment2"])
let flag = try await client.getFlag(session: session, name: "FlagName")
```

You can also send arbitrary event(s) to the server:

```swift
let event = Event(name: "gameLaunched", timestamp: Date())
try await client.event(session: session, event: event)
```


## License

This project is licensed under the [Apache-2 License](https://github.com/heroiclabs/nakama-swift/blob/master/LICENSE).

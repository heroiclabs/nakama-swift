Nakama Swift
============

> Swift client for Nakama server.

Nakama is an [open-source](https://github.com/heroiclabs/nakama) distributed server for social and realtime games and apps. For more information have a look at the [documentation](https://heroiclabs.com/docs/).

This client implements the protocol and all features available in the server. It is compatible with Swift 3.1+.

If you encounter any issues with the server you can generate diagnostics for us with the [doctor](https://heroiclabs.com/docs/install-server-cli/#doctor) subcommand. Send these to support@heroiclabs.com or [open an issue](https://github.com/heroiclabs/nakama/issues). If you experience any issues with the client, it can be useful to [enable trace](https://heroiclabs.com/docs/swift-ios-client-guide/#logs-and-errors) to produce detailed logs and [open an issue](https://github.com/heroiclabs/nakama-swift/issues).

## Usage

If your project uses Cocoapods, add the client as a dependency to your "Podfile":

```ruby
use_frameworks!
pod 'Nakama', '~> 0.2'
```

You can use the Swift package manager to add the code as a dependency for your project. Add the client as a dependency to your "Package.swift" file.

```swift
let package = Package(
  // ...
  dependencies: [
    .Package(url: "https://github.com/heroiclabs/nakama-swift.git", Version(0,2,0)),
  ]
)
```

We have a guide which covers how to use the client with lots of code examples:

https://heroiclabs.com/docs/swift-ios-client-guide/

To create a client which can connect to the Nakama server with the default settings.

```swift
import Nakama

public class NakamaSessionManager {
  private let client: Client;

  init() {
    client = Builder("defaultkey")
        .host("127.0.0.1")
        .port(7350)
        .ssl(false)
        .build()
  }
}
```

## Contribute

To build the codebase you will need to install these dependencies:

* Swift 3.1+
* XCode 8.3+

You must clone the repository and can (optionally) generate updated protocol buffers definitions if needed.

```shell
$> git clone git@github.com:heroiclabs/nakama-swift.git --recursive
$> swift package fetch
$> cd .build/checkouts/swift-protobuf.git--7219529775138357838/
$> swift build -c release -Xswiftc -static-stdlib
$> cd ../../..
$> protoc --plugin=./.build/checkouts/swift-protobuf.git--7219529775138357838/.build/release/protoc-gen-swift --swift_out=Sources/Nakama/. server/server/api.proto
$> mv Sources/Nakama/server/server/api.pb.swift Sources/Nakama/Server.Api.pb.swift
$> swift package generate-xcodeproj
```

### Development

With the codebase setup you can build and test.

```shell
$> swift build
$> swift test
```

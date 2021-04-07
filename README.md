Nakama Swift
============

> Swift client for Nakama server.

Nakama is an [open-source](https://github.com/heroiclabs/nakama) distributed server for social and realtime games and apps. For more information have a look at the [documentation](https://heroiclabs.com/docs/).

This client implements the protocol and all features available in the server. It is compatible with Swift 5.3+.

If you encounter any issues with the server you can generate diagnostics for us with the [doctor](https://heroiclabs.com/docs/install-server-cli/#doctor) subcommand. Send these to support@heroiclabs.com or [open an issue](https://github.com/heroiclabs/nakama/issues). If you experience any issues with the client, it can be useful to [enable trace](https://heroiclabs.com/docs/swift-ios-client-guide/#logs-and-errors) to produce detailed logs and [open an issue](https://github.com/heroiclabs/nakama-swift/issues).

## Usage

If your project uses Cocoapods, add the client as a dependency to your "Podfile":

```ruby
use_frameworks!
pod 'Nakama', '~> 2.0'
```

You can use the Swift package manager to add the code as a dependency for your project. Add the client as a dependency to your "Package.swift" file.

```swift
let package = Package(
  // ...
  dependencies: [
    .Package(url: "https://github.com/heroiclabs/nakama-swift.git", Version(2,0,0)),
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

* Swift 4.2+
* XCode 10+

You must clone the repository and can (optionally) generate updated protocol buffers definitions if needed.

```shell
$> git clone git@github.com:heroiclabs/nakama-swift.git --recursive
$> swift package fetch
$> protoc -I./ -I/usr/local/include -I$GOPATH/src -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway --swift_out=./Sources/Nakama/2.XClient/ --swiftgrpc_out=./Sources/Nakama/2.XClient/ --plugin=grpc ./proto/api.proto
$> protoc -I./ -I/usr/local/include -I$GOPATH/src -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway --swift_out=./Sources/Nakama/2.XClient/ --swiftgrpc_out=./Sources/Nakama/2.XClient/ --plugin=grpc ./proto/apigrpc.proto
$> swift package generate-xcodeproj
```

### Development

With the codebase setup you can build and test.

```shell
$> swift build
$> swift test
```

### GRPC Documentation 

This is explain how to implement it 
- https://docs.servicestack.net/grpc-swift 
- https://levelup.gitconnected.com/swift-grpc-577ce1a4d1b7


To generate documentation, you'll need to install `jazzy`:

```
[sudo] gem install jazzy
```

Then invoke Jazzy like the following:

```
jazzy \
  --clean \
  --author "Heroic Labs" \
  --author_url "https://heroiclabs.com" \
  --github_url "https://github.com/heroiclabs/nakama-swift" \
  --github-file-prefix "https://github.com/heroiclabs/nakama-swift/tree/master" \
  --root-url "https://heroiclabs.github.io/nakama-swift/" \
  --xcodebuild-arguments -project,"$(pwd)/Nakama.xcodeproj",-scheme,Nakama-Package \
  --readme "$(pwd)/README.md" \
  --module "Nakama" \
  --source-directory "Sources/Nakama" \
  --output docs/ \
  --theme fullwidth
```

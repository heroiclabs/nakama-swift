Nakama Swift
============

> Swift client for Nakama server.

## Setup

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

## Development

```shell
$> swift build
$> swift test
```

## Package

```swift
dependencies: [
    .Package(url: "https://github.com/heroiclabs/nakama-swift.git", Version(0,1,0))
]
```

Nakama Swift
============

> Swift client for Nakama server.

## Setup

```shell
$> git clone git@github.com:heroiclabs/nakama-java.git --recursive
$> brew install protobuf-swift
$> protoc --swift_out=Sources/. server/server/api.proto
$> swift package generate-xcodeproj
```

## Development

```shell
$> swift build
```

## Package

```swift
dependencies: [
    .Package(url: "https://github.com/heroiclabs/nakama-swift.git", Version(0,1,0))
]
```

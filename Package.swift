// swift-tools-version:5.3
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

import PackageDescription

let package = Package(
    name: "Nakama",
    products: [
        .library(name: "Nakama", targets: ["Nakama"])
    ],    
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.26.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.10.4"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.9.2"),
        .package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", from: "1.14.0"),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "3.1.1"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.13.0")
    ],
    targets: [
        // The main GRPC module.
        .target(
        name: "Nakama",
        dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOFoundationCompat", package: "swift-nio"),
            .product(name: "NIOTransportServices", package: "swift-nio-transport-services"),
            .product(name: "NIOSSL", package: "swift-nio-ssl"),
            .product(name: "GRPC", package: "grpc-swift"),
            "SwiftProtobuf",
            "PromiseKit",
            "Starscream"
        ]
        ), // and its tests.
        .testTarget(
        name: "NakamaTests",
        dependencies: ["Nakama"]
        )
    ]
)

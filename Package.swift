// swift-tools-version:3.1
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
    dependencies: [
        .Package(url: "https://github.com/apple/swift-protobuf.git", Version(0,9,26)),
        .Package(url: "https://github.com/daltoniam/Starscream.git", majorVersion: 2),
        .Package(url: "https://github.com/mxcl/PromiseKit.git", majorVersion: 4)
    ]
)

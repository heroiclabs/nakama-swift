#!/usr/bin/env bash

# Copyright 2021 The Nakama Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

protoc --plugin protoc-gen-swift -I. --swift_opt=FileNaming=DropPath --swift_opt=Visibility=Public --swift_out=../Sources/Nakama ./github.com/heroiclabs/nakama-common/api/api.proto

protoc --plugin protoc-gen-swift -I. --swift_opt=FileNaming=DropPath --swift_opt=Visibility=Public --swift_out=../Sources/Nakama ./github.com/heroiclabs/nakama-common/rtapi/realtime.proto

protoc --plugin protoc-gen-swift --plugin protoc-gen-grpc-swift --swift_opt=plugins=grpc --grpc-swift_out=../Sources/Nakama --swift_opt=paths=source_relative -I. -I./grpc-gateway-2.0.0-beta.5/third_party/googleapis apigrpc.proto

#!/usr/bin/env bash
#
# Regenerates the Swift model layer from the vendored proto files.
#
# Both targets share templates/Api.swift.tmpl and differ only by --prefix, which
# names the generated types (NakamaX / SatoriX) and the module's error enum. The
# REST client half is emitted only when the proto declares rpcs. The generator
# itself is a straight copy of nakama-unreal-codegen/cmd/codegen -- keep it that
# way and put target-specific logic in templates/.

set -o errexit
set -o nounset
set -o pipefail

cd "$(dirname "$0")"

go run . \
  --template templates/Api.swift.tmpl \
  --prefix Nakama \
  --package nakama.api \
  --proto ../proto/github.com/heroiclabs/nakama-common/api/api.proto \
  --proto ../proto/apigrpc.proto \
  > ../Sources/Nakama/Nakama.gen.swift

go run . \
  --template templates/Api.swift.tmpl \
  --prefix Satori \
  --package satori.api \
  --proto ../proto/satori/satori.proto \
  > ../Sources/Satori/Satori.gen.swift

# Realtime models. api.proto first so the realtime protos' api.* references resolve;
# --package limits emission to the realtime types themselves.
go run . \
  --template templates/Realtime.swift.tmpl \
  --prefix Nakama \
  --package nakama.realtime \
  --proto ../proto/github.com/heroiclabs/nakama-common/api/api.proto \
  --proto ../proto/github.com/heroiclabs/nakama-common/rtapi/realtime.proto \
  > ../Sources/Nakama/NakamaRealtime.gen.swift

echo "[+] Generated Sources/Nakama/{Nakama,NakamaRealtime}.gen.swift and Sources/Satori/Satori.gen.swift"

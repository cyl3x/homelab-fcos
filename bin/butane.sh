#!/usr/bin/env -S bash -e
# yq - https://github.com/mikefarah/yq

workdir="$(dirname "$0")/.."

cp "$workdir/core-os/server.base.bu" "$workdir/server.bu"
while yq -e '.butane[]' "$workdir/server.bu" &>/dev/null; do
    yq -Pi '.butane[] as $bu ireduce ((. | del(.butane)); . *+ load("core-os/" + $bu))' "$workdir/server.bu"
done

butane --files-dir "$workdir/core-os" "$@" "$workdir/server.bu"
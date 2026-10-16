#!/bin/bash
# Prints "<hex of BLAKE3> <asset name>" for each release asset in the list.
# The asset name is the base58 text of the digest (the hash form of roc).
# tests/roc_hashes.roc has the output. Needs the network.
# Usage: scripts/blake3-vectors.sh [ROC]
set -euo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd)
ROC=${1:-${ROC:-roc}}
W=$HERE/.work/b3
export XDG_CACHE_HOME=$HERE/.work/xdg ROC_CACHE_DIR=$HERE/.work/xdg/roc
ASSETS=(
	"https://github.com/lukewilliamboswell/roc-parser/releases/download/2.0.0/7CLzCK6qUz7zmj6nvBxMEFu11HPwQTnCovKiyWzDSLTW.tar.zst"
	"https://github.com/roc-lang/unicode/releases/download/4.2.0/4W8SHzvwet9hH9qZewJ1J1CVQoH7YKA6zyijWFTB3y1w.tar.zst"
)
for url in "${ASSETS[@]}"; do
	name=$(basename "$url" .tar.zst)
	d=$W/$name
	mkdir -p "$d"
	[ -f "$d/asset.tar.zst" ] || curl -sSfL -o "$d/asset.tar.zst" "$url"
	cp "$HERE/tests/tools/blake3_hex.roc" "$d/"
	echo "$("$ROC" "$d/blake3_hex.roc") $name"
done

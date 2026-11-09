#!/bin/sh
set -eu

ICON_NAME="AppIcon"
MASTER_SIZE="1024"
ICON_SIZES="16 32 128 256 512"
RETINA_SCALE="2"
RESOURCES_DIR="Resources"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
MASTER="$WORK/$ICON_NAME-$MASTER_SIZE.png"
ICONSET="$WORK/$ICON_NAME.iconset"

swift scripts/make-icon.swift "$MASTER" >&2
mkdir -p "$ICONSET"
for SIZE in $ICON_SIZES; do
    RETINA=$((SIZE * RETINA_SCALE))
    sips -z "$SIZE" "$SIZE" "$MASTER" --out "$ICONSET/icon_${SIZE}x${SIZE}.png" >/dev/null
    sips -z "$RETINA" "$RETINA" "$MASTER" --out "$ICONSET/icon_${SIZE}x${SIZE}@${RETINA_SCALE}x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$RESOURCES_DIR/$ICON_NAME.icns"
echo "$ROOT/$RESOURCES_DIR/$ICON_NAME.icns"

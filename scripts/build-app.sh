#!/bin/sh
set -eu

APP_PRODUCT="NommoControl"
CLI_PRODUCT="nommo"
APP_NAME="Nommo Control"
APP_ARCHIVE_PREFIX="NommoControl"
CLI_ARCHIVE_PREFIX="nommo"
CLI_IDENTIFIER="io.github.feroxes.nommo"
ARCHITECTURES="arm64 x86_64"
PLATFORM="macos"
TAG_PREFIX="v"
FALLBACK_VERSION="0.0.0"
BUILD_DIR="build"
SCRATCH_DIR=".build/arch"
CHECK_SCRIPT="scripts/check-app.sh"
SPARKLE_FRAMEWORK="Sparkle.framework"
SPARKLE_LICENSE_SOURCE="artifacts/sparkle/Sparkle/LICENSE"
SPARKLE_LICENSE_NAME="Sparkle-LICENSE.txt"
PLIST_SOURCE="Resources/Info.plist"
ICON_SOURCE="Resources/AppIcon.icns"
PLIST_FORMAT="xml1"
IDENTIFIER_KEY="CFBundleIdentifier"
SHORT_VERSION_KEY="CFBundleShortVersionString"
BUILD_VERSION_KEY="CFBundleVersion"
MINIMUM_SYSTEM_KEY="LSMinimumSystemVersion"
INFO_PLIST_SEGMENT="__TEXT"
INFO_PLIST_SECTION="__info_plist"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${NOMMO_VERSION:-$(git describe --tags --always 2>/dev/null || echo "$FALLBACK_VERSION")}"
VERSION="${VERSION#"$TAG_PREFIX"}"
MINIMUM_SYSTEM="$(plutil -extract "$MINIMUM_SYSTEM_KEY" raw "$PLIST_SOURCE")"
SDK_VERSION="$(xcrun --show-sdk-version)"

APP="$BUILD_DIR/$APP_NAME.app"
APP_EXECUTABLE="$APP/Contents/MacOS/$APP_PRODUCT"
PLIST="$APP/Contents/Info.plist"
CLI="$BUILD_DIR/$CLI_PRODUCT"
CLI_PLIST="$ROOT/$SCRATCH_DIR/$CLI_PRODUCT-Info.plist"
SLICES="$BUILD_DIR/slices"
APP_ZIP="$BUILD_DIR/$APP_ARCHIVE_PREFIX-$VERSION.zip"
CLI_ZIP="$BUILD_DIR/$CLI_ARCHIVE_PREFIX-$VERSION.zip"

stamp_version() {
    TARGET_PLIST="$1"
    plutil -replace "$SHORT_VERSION_KEY" -string "$VERSION" "$TARGET_PLIST"
    plutil -replace "$BUILD_VERSION_KEY" -string "$VERSION" "$TARGET_PLIST"
}

record_sdk() {
    SOURCE="$1"
    DESTINATION="$2"
    vtool -set-build-version "$PLATFORM" "$MINIMUM_SYSTEM" "$SDK_VERSION" -replace -output "$DESTINATION" "$SOURCE" >&2
}

embed_sparkle() {
    ARCH="${ARCHITECTURES%% *}"
    SCRATCH="$SCRATCH_DIR/$ARCH"
    BIN_PATH="$(swift build -c release --product "$APP_PRODUCT" --arch "$ARCH" --scratch-path "$SCRATCH" --show-bin-path)"
    mkdir -p "$APP/Contents/Frameworks"
    ditto "$BIN_PATH/$SPARKLE_FRAMEWORK" "$APP/Contents/Frameworks/$SPARKLE_FRAMEWORK"
    cp "$SCRATCH/$SPARKLE_LICENSE_SOURCE" "$APP/Contents/Resources/$SPARKLE_LICENSE_NAME"
}

build_universal() {
    PRODUCT="$1"
    OUTPUT="$2"
    shift 2
    rm -rf "$SLICES"
    mkdir -p "$SLICES"
    for ARCH in $ARCHITECTURES; do
        SCRATCH="$SCRATCH_DIR/$ARCH"
        BIN_PATH="$(swift build -c release --product "$PRODUCT" --arch "$ARCH" --scratch-path "$SCRATCH" "$@" --show-bin-path)"
        rm -f "$BIN_PATH/$PRODUCT"
        swift build -c release --product "$PRODUCT" --arch "$ARCH" --scratch-path "$SCRATCH" "$@" >&2
        record_sdk "$BIN_PATH/$PRODUCT" "$SLICES/$ARCH"
    done
    lipo -create "$SLICES"/* -output "$OUTPUT"
    rm -rf "$SLICES"
}

archive() {
    ditto -c -k --norsrc --noextattr "$@"
}

rm -rf "$APP" "$CLI" "$SLICES" "$APP_ZIP" "$CLI_ZIP" "$CLI_PLIST"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$SCRATCH_DIR"

build_universal "$APP_PRODUCT" "$APP_EXECUTABLE"
cp "$PLIST_SOURCE" "$PLIST"
cp "$ICON_SOURCE" "$APP/Contents/Resources/"
stamp_version "$PLIST"
embed_sparkle
codesign --force --sign - "$APP" >&2
"$CHECK_SCRIPT" "$APP" >&2
archive --keepParent "$APP" "$APP_ZIP"

plutil -create "$PLIST_FORMAT" "$CLI_PLIST"
plutil -replace "$IDENTIFIER_KEY" -string "$CLI_IDENTIFIER" "$CLI_PLIST"
stamp_version "$CLI_PLIST"
build_universal "$CLI_PRODUCT" "$CLI" -Xlinker -sectcreate -Xlinker "$INFO_PLIST_SEGMENT" -Xlinker "$INFO_PLIST_SECTION" -Xlinker "$CLI_PLIST"
codesign --force --sign - --identifier "$CLI_IDENTIFIER" "$CLI" >&2
archive "$CLI" "$CLI_ZIP"

echo "$ROOT/$APP_ZIP"
echo "$ROOT/$CLI_ZIP"

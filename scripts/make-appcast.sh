#!/bin/sh
set -eu

APP_NAME="Nommo Control"
APP_ARCHIVE_PREFIX="NommoControl"
BUILD_DIR="build"
APPCAST_NAME="appcast.xml"
SCRATCH_PATH=".build/arch/arm64"
GENERATE_APPCAST="artifacts/sparkle/Sparkle/bin/generate_appcast"
NOTES_SCRIPT="scripts/release-notes.sh"
VERIFY_SCRIPT="scripts/verify-update-signature.swift"
REPOSITORY_URL="https://github.com/feroxes/razer-nommo-v2-macos"
TAG_PREFIX="v"
PUBLIC_KEY_PLIST_KEY="SUPublicEDKey"
PLIST_PATH_IN_REPOSITORY="Resources/Info.plist"
PRERELEASE_MARKER="-"
USAGE="usage: make-appcast.sh <version>"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${1:?$USAGE}"
: "${SPARKLE_PRIVATE_KEY:?SPARKLE_PRIVATE_KEY is not set or empty.}"

ARCHIVE="$APP_ARCHIVE_PREFIX-$VERSION.zip"
ARCHIVE_PATH="$BUILD_DIR/$ARCHIVE"
PLIST_IN_ARCHIVE="$APP_NAME.app/Contents/Info.plist"
APPCAST="$BUILD_DIR/$APPCAST_NAME"
DOWNLOAD_PATH="/$TAG_PREFIX$VERSION/$ARCHIVE"

fail() {
    echo "::error::$1"
    exit 1
}

[ -f "$ARCHIVE_PATH" ] || fail "$ARCHIVE_PATH does not exist."

PUBLIC_KEY="$(unzip -p "$ARCHIVE_PATH" "$PLIST_IN_ARCHIVE" | plutil -extract "$PUBLIC_KEY_PLIST_KEY" raw -)"

PREVIOUS_TAG="$(git tag --list "$TAG_PREFIX*" --sort=-v:refname | grep -v -e "$PRERELEASE_MARKER" | grep -v -x -e "$TAG_PREFIX$VERSION" | head -n 1 || true)"
if [ -n "$PREVIOUS_TAG" ]; then
    PREVIOUS_KEY="$(git show "$PREVIOUS_TAG:$PLIST_PATH_IN_REPOSITORY" | plutil -extract "$PUBLIC_KEY_PLIST_KEY" raw - 2>/dev/null || true)"
    if [ -n "$PREVIOUS_KEY" ] && [ "$PREVIOUS_KEY" != "$PUBLIC_KEY" ]; then
        fail "$PUBLIC_KEY_PLIST_KEY in $ARCHIVE_PATH differs from the key in $PREVIOUS_TAG. Installed apps verify updates against their own key, so a changed key ships an update nobody can install."
    fi
fi

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
ARCHIVES="$STAGING/archives"
GENERATED="$STAGING/$APPCAST_NAME"
mkdir "$ARCHIVES"
cp "$ARCHIVE_PATH" "$ARCHIVES/$ARCHIVE"

NOTES="$("$NOTES_SCRIPT" "$VERSION")"
if printf '%s' "$NOTES" | grep -q '[^[:space:]]'; then
    printf '%s\n' "$NOTES" > "$ARCHIVES/$APP_ARCHIVE_PREFIX-$VERSION.md"
fi

printf '%s' "$SPARKLE_PRIVATE_KEY" | "$SCRATCH_PATH/$GENERATE_APPCAST" \
    --ed-key-file - \
    --embed-release-notes \
    --download-url-prefix "$REPOSITORY_URL/releases/download/$TAG_PREFIX$VERSION/" \
    --link "$REPOSITORY_URL" \
    -o "$GENERATED" \
    "$ARCHIVES"

query() {
    xmllint --xpath "$1" "$GENERATED"
}

ITEM_COUNT="$(query 'count(//item)')"
[ "$ITEM_COUNT" = "1" ] || fail "The appcast has $ITEM_COUNT items, expected 1."

ITEM_VERSION="$(query 'string(//item/*[local-name()="version"])')"
ITEM_SHORT_VERSION="$(query 'string(//item/*[local-name()="shortVersionString"])')"
ITEM_URL="$(query 'string(//item/enclosure/@url)')"
SIGNATURE="$(query 'string(//item/enclosure/@*[local-name()="edSignature"])')"

[ "$ITEM_VERSION" = "$VERSION" ] || fail "sparkle:version is $ITEM_VERSION, expected $VERSION."
[ "$ITEM_SHORT_VERSION" = "$VERSION" ] || fail "sparkle:shortVersionString is $ITEM_SHORT_VERSION, expected $VERSION."
case "$ITEM_URL" in
    *"$DOWNLOAD_PATH") ;;
    *) fail "The enclosure URL is $ITEM_URL, expected it to end with $DOWNLOAD_PATH." ;;
esac
[ -n "$SIGNATURE" ] || fail "The appcast item has no sparkle:edSignature."

swift "$VERIFY_SCRIPT" "$ARCHIVE_PATH" "$SIGNATURE" "$PUBLIC_KEY" || fail "The signature does not verify against $PUBLIC_KEY_PLIST_KEY in $ARCHIVE_PATH."

cp "$GENERATED" "$APPCAST"
echo "$ROOT/$APPCAST"

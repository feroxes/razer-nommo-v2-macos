#!/bin/sh
set -eu

APP_PRODUCT="NommoControl"
FRAMEWORKS_PATH="Contents/Frameworks"
SPARKLE_FRAMEWORK="Sparkle.framework"
EXPECTED_RPATH="@executable_path/../Frameworks"
EXPECTED_LINK="@rpath/Sparkle.framework/Versions/B/Sparkle"
REQUIRED_KEYS="SUFeedURL SUPublicEDKey"
SHORT_VERSION_KEY="CFBundleShortVersionString"
BUILD_VERSION_KEY="CFBundleVersion"
FALSE_KEYS="SUAllowsAutomaticUpdates SUEnableSystemProfiling"
FORBIDDEN_KEY="SUEnableAutomaticChecks"
FEED_URL_KEY="SUFeedURL"
FEED_URL_SCHEME="https://"
USAGE_STATUS=2

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <path to .app>" >&2
    exit "$USAGE_STATUS"
fi

APP="$1"
EXECUTABLE="$APP/Contents/MacOS/$APP_PRODUCT"
PLIST="$APP/Contents/Info.plist"

fail() {
    echo "::error::$1"
    exit 1
}

codesign --verify --deep --strict "$APP" || fail "$APP fails codesign verification."

[ -d "$APP/$FRAMEWORKS_PATH/$SPARKLE_FRAMEWORK" ] || fail "$APP has no $SPARKLE_FRAMEWORK in $FRAMEWORKS_PATH."

otool -l "$EXECUTABLE" | grep -q "path $EXPECTED_RPATH " || fail "$EXECUTABLE has no LC_RPATH $EXPECTED_RPATH."
otool -L "$EXECUTABLE" | grep -q "$EXPECTED_LINK" || fail "$EXECUTABLE does not link $EXPECTED_LINK."

for KEY in $REQUIRED_KEYS; do
    VALUE="$(plutil -extract "$KEY" raw "$PLIST" 2>/dev/null || true)"
    [ -n "$VALUE" ] || fail "$KEY is missing or empty in $PLIST."
done

SHORT_VERSION="$(plutil -extract "$SHORT_VERSION_KEY" raw "$PLIST")"
BUILD_VERSION="$(plutil -extract "$BUILD_VERSION_KEY" raw "$PLIST")"
[ "$SHORT_VERSION" = "$BUILD_VERSION" ] || fail "$BUILD_VERSION_KEY is $BUILD_VERSION, expected $SHORT_VERSION."

for KEY in $FALSE_KEYS; do
    VALUE="$(plutil -extract "$KEY" raw "$PLIST" 2>/dev/null || true)"
    [ "$VALUE" = "false" ] || fail "$KEY is '$VALUE' in $PLIST, expected false."
done

if plutil -extract "$FORBIDDEN_KEY" raw "$PLIST" >/dev/null 2>&1; then
    fail "$FORBIDDEN_KEY is set in $PLIST; leave it unset so Sparkle asks the user."
fi

FEED_URL="$(plutil -extract "$FEED_URL_KEY" raw "$PLIST")"
case "$FEED_URL" in
    "$FEED_URL_SCHEME"*) ;;
    *) fail "$FEED_URL_KEY is $FEED_URL in $PLIST, expected it to start with $FEED_URL_SCHEME." ;;
esac

#!/bin/sh
set -eu

CHANGELOG="CHANGELOG.md"
SECTION_PREFIX="## ["
USAGE="usage: release-notes.sh <version>"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:?$USAGE}"

awk -v prefix="$SECTION_PREFIX" -v heading="$SECTION_PREFIX$VERSION]" '
    index($0, prefix) == 1 { if (found) exit; found = index($0, heading) == 1; next }
    /^\[[^]]+\]: / { if (found) exit }
    found { print }
' "$ROOT/$CHANGELOG"

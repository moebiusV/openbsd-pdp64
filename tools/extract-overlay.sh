#!/bin/sh
# The other way: from a working OpenBSD tree, write the port's new files to overlay/ and the
# changes to files OpenBSD has to patches/port.patch. Run after editing in the tree.
set -eu
. "$(dirname "$0")/_tree.sh"
cd "$OPENBSD"
git ls-files -o --exclude-standard | while read -r f; do
    mkdir -p "$ROOT/overlay/$(dirname "$f")"
    cp -p "$f" "$ROOT/overlay/$f"
done
git diff --binary HEAD > "$ROOT/patches/port.patch"
[ -s "$ROOT/patches/port.patch" ] || rm -f "$ROOT/patches/port.patch"
echo "overlay/ and patches/ updated from $OPENBSD"

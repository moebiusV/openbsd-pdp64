#!/bin/sh
# Apply the overlay to an OpenBSD tree: copy overlay/ over it, then apply patches/*.patch.
# The patches are checked first, so a tree that has moved on is not left half changed.
set -eu
. "$(dirname "$0")/_tree.sh"
for p in "$ROOT"/patches/*.patch; do
    [ -e "$p" ] || continue
    git -C "$OPENBSD" apply --check "$p" || { echo "does not apply: $p (the tree is not at BASE?)" >&2; exit 1; }
done
# overlay/README.md describes the directory; it is not a file of the port
(cd "$ROOT/overlay" && tar --exclude=./README.md -cf - .) | (cd "$OPENBSD" && tar xf -)
for p in "$ROOT"/patches/*.patch; do
    [ -e "$p" ] || continue
    git -C "$OPENBSD" apply "$p"
done
echo "overlay applied to $OPENBSD"

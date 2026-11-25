#!/bin/sh
# A unified diff of the whole port against OpenBSD, the form a patch for tech@ takes:
# apply the overlay to a scratch worktree of the tree at BASE and print the diff.
set -eu
. "$(dirname "$0")/_tree.sh"
W=$(mktemp -d)
git -C "$OPENBSD" worktree add -q --detach "$W/t" "$(cat "$ROOT/BASE")"
OPENBSD_SRC="$W/t" "$ROOT/tools/apply-overlay.sh" >&2
git -C "$W/t" add -A
git -C "$W/t" diff --cached --binary
git -C "$OPENBSD" worktree remove --force "$W/t"
rmdir "$W"

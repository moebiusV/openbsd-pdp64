#!/bin/sh
# Clone OpenBSD into ./openbsd (git-ignored) and check out the commit in BASE.
# A blobless clone: the history is complete, file contents come as they are needed.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
[ -e "$ROOT/openbsd" ] && { echo "$ROOT/openbsd exists; nothing done" >&2; exit 1; }
git clone --filter=blob:none -o upstream https://github.com/openbsd/src.git "$ROOT/openbsd"
git -C "$ROOT/openbsd" remote set-url --push upstream DISABLED_no_push_to_openbsd
git -C "$ROOT/openbsd" checkout -q "$(cat "$ROOT/BASE")"

# Sourced by the other tools: sets OPENBSD (the OpenBSD tree to work on) and ROOT (this repository).
#   OPENBSD_SRC=/path   use that tree
#   otherwise ./openbsd (see tools/openbsd-checkout.sh), then ~/claude/openbsd-src
ROOT=$(cd "$(dirname "$0")/.." && pwd)
for d in "${OPENBSD_SRC:-}" "$ROOT/openbsd" "$HOME/claude/openbsd-src"; do
    [ -n "$d" ] && [ -d "$d/sys/arch" ] && OPENBSD=$d && break
done
[ -n "${OPENBSD:-}" ] || { echo "no OpenBSD tree: set OPENBSD_SRC or run tools/openbsd-checkout.sh" >&2; exit 1; }

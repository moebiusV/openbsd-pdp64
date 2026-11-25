# How this repository is laid out

The repository holds only what the port adds or changes; the OpenBSD tree itself is fetched separately (`tools/openbsd-checkout.sh`).

| | |
|---|---|
| `BASE` | the OpenBSD commit the overlay is made against |
| `overlay/` | new files, at the paths they have in the OpenBSD tree (`overlay/sys/arch/pdp64/...` is `sys/arch/pdp64/...`) |
| `patches/` | unified diffs of the files OpenBSD already has and the port must change |
| `tools/openbsd-checkout.sh` | clone OpenBSD at `BASE` into `./openbsd` (git-ignored) |
| `tools/apply-overlay.sh` | copy `overlay/` over an OpenBSD tree and apply `patches/` |
| `tools/extract-overlay.sh` | the other way: write `overlay/` and `patches/` from a working tree |
| `tools/make-submission-diff.sh` | the whole port as one unified diff against OpenBSD, the form a patch for `tech@` takes |
| `tools/asm-inventory.sh` | the assembly inventory of `docs/asm-inventory.md` |
| `tools/pcc-split.py` | how the `dmr`, `pdp64` and `aarch64` branches of [pcc](https://github.com/moebiusV/pcc) were made |

The tools find the OpenBSD tree in `$OPENBSD_SRC`, then `./openbsd`, then `~/claude/openbsd-src`.

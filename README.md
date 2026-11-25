# OpenBSD on the pdp64

The port of OpenBSD to the [pdp64](https://moebiusv.github.io/pdp64/), a 64-bit successor to the PDP-11, and the plan for it. The first thing the plan says is what has to be ready before a cross-compiled OpenBSD can boot in QEMU; the port itself is written once the pdp64 settles.

This repository is an **overlay** on the OpenBSD tree, not a copy of it: it holds only what the port adds or changes.

- [The plan](PLAN.md): what must be ready first (architecture decisions, the emulator, the toolchain), the repositories, and what is done.
- [Assembly inventory](docs/asm-inventory.md) and [translation verdicts](docs/translation-verdicts.md): every assembly file the port needs, taken from the riscv64 and arm64 ports, and what happens to each on the pdp64.
- [What LLVM, clang and lld must provide](docs/llvm-requirements.md).
- [What each OpenBSD policy and mitigation costs on the pdp64](docs/mitigation-costs.md): where the design makes it cheaper, and where it does not.
- [The machine-dependent C files to write](docs/md-c-files.md).

## The overlay

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

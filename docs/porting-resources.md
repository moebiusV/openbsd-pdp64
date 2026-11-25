# Bringing OpenBSD up on a new CPU architecture: the documentation

Everything we could find on porting OpenBSD to a new CPU architecture, collected in one place. Compiled on 2026-11-25 by reading the pages and the source tree themselves (not just search results). The date shown with an entry is the page's own date where it has one. Entries marked **old** are many years out of date, and **uncertain** means we could not read the page or could not confirm what it says. If you know of something missing, open an issue on [openbsd-pdp64](https://github.com/moebiusV/openbsd-pdp64).

## The short version

- There is **no current "how to port OpenBSD" guide**. The only OpenBSD-written how-to is a 2005 slide deck from the days of GCC. Most of the knowledge is in the source tree itself: the [riscv64](https://github.com/openbsd/src/tree/master/sys/arch/riscv64) and [arm64](https://github.com/openbsd/src/tree/master/sys/arch/arm64) ports are the working examples, and recent ports are the template.
- OpenBSD's own definition of a supported platform is on [plat.html](https://www.openbsd.org/plat.html): install media known to work, **the architecture can compile itself**, and most basic tools exist. [FAQ 5](https://www.openbsd.org/faq/faq5.html) says the cross-compilation tools exist mainly for developers bringing up a new platform and are not maintained for general use.
- **Licensing is the one hard written rule** ([Copyright Policy](https://www.openbsd.org/policy.html)): ISC is preferred for new code, BSD-style licences are acceptable, Apache 2 is not and GPL is generally not accepted into the base system. LLVM itself is Apache 2.0 with LLVM exceptions, so a new LLVM back end is a licence question to settle with the developers early (OpenBSD does carry LLVM today, but we did not find what the policy says about it).
- There is **no written policy for accepting a new architecture** (hardware, maintainers, ports-tree cost); patches go to `tech@`.

## 1. Official documentation and the source tree

*The manual server, `man.openbsd.org`, was not answering when this page was published (2026-11-25); its pages were confirmed earlier the same day, so the links below are the standard ones.*

| Page | What it contains | Date / status |
|---|---|---|
| [FAQ 5, Building the System From Source](https://www.openbsd.org/faq/faq5.html) | The build steps (binaries, source, kernel, userland, release, Xenocara) and "Preparing a Diff". Says cross-compilation exists mainly for bringing up a new platform; OpenBSD builds natively. No porting section. | current |
| [Platforms](https://www.openbsd.org/plat.html) | The 13 supported platforms (alpha, amd64, arm64, armv7, hppa, i386, landisk, luna88k, macppc, octeon, powerpc64, riscv64, sparc64) and the discontinued ones. The criteria for "supported" (see above). Says no porting effort is under way and that in-progress ports are not officially supported. | current |
| Per-platform pages: [riscv64](https://www.openbsd.org/riscv64.html), [arm64](https://www.openbsd.org/arm64.html), [powerpc64](https://www.openbsd.org/powerpc64.html) | Hardware lists and drivers. About hardware, not about how to port. | current |
| [release(8)](https://man.openbsd.org/release.8) | The eight steps to build a release (sources, kernel, base, release, Xenocara, boot and install images). | source dated 2026-08-25 |
| [pmap(9)](https://man.openbsd.org/pmap.9) | "Machine dependent interface to the MMU": the main machine-dependent contract for memory management. | current |
| [bus_space(9)](https://man.openbsd.org/bus_space.9) and [bus_dma(9)](https://man.openbsd.org/bus_dma.9) | The device-access and DMA interfaces a port implements in `machine/bus.h`. | current |
| [style(9)](https://man.openbsd.org/style.9) | Kernel source style. | current |
| [boot_config(8)](https://man.openbsd.org/boot_config.8) | The boot-time configuration of the kernel. | current |
| [intro(9)](https://man.openbsd.org/intro.9) | Only says that section 9 documents kernel internals. | current |
| [Makefile.cross](https://github.com/openbsd/src/blob/master/Makefile.cross) | The `cross-tools` and `cross-distrib` targets. Maps `TARGET` to `TARGET_ARCH`, has a hard-coded `LP64_ARCH` list (a new 64-bit arch must be added), and builds a cross clang for architectures in `CLANG_ARCH`. | revision 1.113, 2026-07-15 |
| The ports in the tree | `sys/arch/riscv64` (`compile`, `conf`, `dev`, `include`, `riscv64`, `stand`), `distrib/riscv64`, `distrib/notes/riscv64`, `lib/libc/arch/riscv64`, `lib/libm/arch/riscv64`, `lib/csu/riscv64`, `libexec/ld.so/riscv64`, `etc/etc.riscv64`, `share/man/man4/man4.riscv64`. There is no README or NOTES file in `sys/arch/riscv64`, and no `sys/lib/libkern/arch/riscv64`. The only per-architecture notes are `distrib/notes/<arch>/`. | current |
| [OpenBSD anonymous CVS](https://www.openbsd.org/anoncvs.html) and the [git mirror](https://github.com/openbsd/src) | CVS is the source of truth; the GitHub repository is a read-only conversion of the main branch whose description says "Send any diffs to the tech@ mailing list". | current |

The [FAQ index](https://www.openbsd.org/faq/) has no FAQ on porting the system; its links to the "Porter's Handbook" are about the ports tree, a different thing.

## 2. Case studies and talks

**The one how-to (old):** Niall O'Higgins and Uwe Stuehler, [Porting OpenBSD](https://www.openbsd.org/papers/ven05-niallo-uwe/slides.pdf) (OpenCON 2005, 88 slides; also [mirrored](https://people.freebsd.org/~chuckr/arm/PortingOpenBSD.pdf)). What it takes (about 20 developers owning the hardware, a user community); the criteria for full support; copying and renaming `sys/arch/<m>`, the man pages, `etc/etc.<m>` and `distrib/`; cross development with `make cross-tools` and `cross-distrib`; the boot loader; `config(8)`; getting the RAMDISK kernel working first; serial console, interrupt controller and bus drivers first; NFS root until the disk driver works; going native. The toolchain advice is from the GCC era and is superseded by clang and lld.

**riscv64** (the template for us):
- Bamsch, He, Li and Waghela, [Porting OpenBSD to RISC-V ISA](https://www.openbsd.org/papers/Porting_OpenBSD_to_RISCV_FinalReport.pdf) (San José State University project report, May 2020): early bootstrap in assembly, the Sv39 pmap, trap handlers, fork and context switch, device attach; the kernel booted under QEMU up to `init`. The first `sys/arch/riscv64` commit (`baed8f062d`, 2021-04-23, "Initial import of OpenBSD/riscv64") cites this report and credits the four students "with additional work by Dale Rahn".

**arm64:** the import commit (`f24071e5a8`, 2016-12-17) says the port is "based on the PowerPC pmap, loongson, arm/armv7 code and FreeBSD aarch64 code. Hard work done by Dale Rahn". Patrick Wildt's [a2k17 hackathon report](https://undeadly.org/cgi?action=article&sid=20170131101827) (2017-01-31, **old**) is first-hand: QEMU first, then real hardware; the first OpenBSD port to drop the in-base GCC for clang and lld, because the in-base binutils was too old for aarch64. Marc Espie's [clang vs gcc: waaaat?](https://www.openbsd.org/papers/lse-clang.pdf) (2017, **old**) dates the switch ("December 17: first arch using clang, arm64").

**powerpc64:** first commit `1386120097`, 2020-05-16, "Planting the first seed for OpenBSD/powerpc64"; 6.8 was the first official release. [Talospace's report](https://www.talospace.com/2020/05/when-will-openpower-openbsd-be-now-soon.html) (2020-05-19) describes it as very preliminary and dependent on firmware.

**Other bring-ups (all old):** Mark Kettenis, [OpenBSD/sun4v](https://www.openbsd.org/papers/eurobsdcon2011-kettenis.pdf) (EuroBSDCon 2011: bare metal, then a guest domain, then the primary domain; the sparc64 history) and [OpenBSD/sparc64](https://www.openbsd.org/papers/opencon07-sparc64.pdf) (OpenCON 2007); Paul Irofti, [Making OpenBSD Useful on the Octeon Network Gear](https://www.openbsd.org/papers/bsdcan2014-octeon_dsr500.pdf) (BSDCan 2014: a MIPS64 bring-up driver by driver); Rainer Giedat, [Porting OpenBSD to MIPS based devices](https://www.openbsd.org/papers/mips32-openbsd.pdf) (OpenCON 2007: a bare-metal serial demo first, then the cross compiler, then the port).

**The ports tree, which a new architecture also costs:** Marc Espie, [Architectures vs the Ports tree: a losing battle?](https://www.openbsd.org/papers/eurobsdcon2022-espie-arches.pdf) (EuroBSDCon 2022, fairly current): cross-compile only for bootstrap, every architecture builds its own packages; the pitfalls a new architecture exposes (strict alignment, endianness, `char` signedness); the baseline-CPU rule. Kurt Mosiejczuk, [Care and Feeding of OpenBSD Porters](https://www.openbsd.org/papers/vbsdcon2019-care-and-feeding.pdf) (vBSDcon 2019, **old**) is about the ports tree, not the OS.

The talks above are listed on the [OpenBSD events page](https://www.openbsd.org/events.html); the [hackathons page](https://www.openbsd.org/hackathons.html) describes the invitation-only developer events.

## 3. The toolchain side: adding an architecture to OpenBSD's clang

No OpenBSD text explains how to add an LLVM target to the base build; the mechanism is visible only in these files (all read from the source):

- [`share/mk/bsd.own.mk`](https://github.com/openbsd/src/blob/master/share/mk/bsd.own.mk) (revision 1.217, 2026-08-20): `CLANG_ARCH`, `GCC4_ARCH` (alpha, hppa, m88k, sh), `LLD_ARCH`, `LLDB_ARCH`, `PIE_ARCH` and `STATICPIE_ARCH`, from which `COMPILER_VERSION`, `BUILD_CLANG`, `LINKER_VERSION` and `AR_VERSION` are derived. A new architecture goes into `CLANG_ARCH`, `LLD_ARCH` and `PIE_ARCH`.
- [`gnu/usr.bin/clang/Makefile.arch`](https://github.com/openbsd/src/blob/master/gnu/usr.bin/clang/Makefile.arch): `LLVM_ARCHS` and the `MACHINE_ARCH` to `LLVM_ARCH` mapping; it builds `LLVM<arch>AsmParser`, `CodeGen`, `Desc`, `Disassembler`, `Info` and (for some) `Utils` libraries, each with its own directory in `gnu/usr.bin/clang`, plus generated tablegen headers in `include/llvm/<arch>`.
- [`gnu/usr.bin/clang/Makefile`](https://github.com/openbsd/src/blob/master/gnu/usr.bin/clang/Makefile) and `Makefile.inc`: the subdirectory order, and `-fno-ret-protector` for host architectures that have retguard.
- [clang-local(1)](https://man.openbsd.org/clang-local): OpenBSD's local behaviour (stack protector and PIE by default, retguard on amd64, arm64, mips64, powerpc and powerpc64). **riscv64 and sparc64 are not on that list, and we found no retguard code in the riscv64 back end**, so a new target has none unless it is added.
- The in-tree LLVM lives in [`gnu/llvm`](https://github.com/openbsd/src/tree/master/gnu/llvm); there is no README about adding an architecture there.

## 4. Other systems and general references

- **NetBSD:** [Adding a new port](https://www.netbsd.org/developers/new-port.html) (current) is the best written checklist we found: copy a similar port's tree, set up a cross compiler, a binary the boot loader accepts, a standalone console binary, a memory-disk kernel, then drivers, plus the project housekeeping around a new port. It maps well onto OpenBSD. Also McGrew and Nelson, [Porting NetBSD to the RISC-V](https://www.bsdcan.org/2019/schedule/attachments/483_riscvnetbsd.pdf) (BSDCan 2019, a student kernel port), and Frank van der Linden, [The AMD64 port](https://www.usenix.org/legacy/events/bsdcon/full_papers/linden/linden.pdf) (BSDCon 2002, **old**).
- **FreeBSD:** the [Architecture Handbook](https://docs.freebsd.org/en/books/arch-handbook/) has no chapter on a new architecture (chapters 1 and 7 on boot and virtual memory are the closest); Doug Rabson, [Early FreeBSD Ports](https://freebsdfoundation.org/wp-content/uploads/2023/06/rabson_early_ports.pdf) (2023) is a short history.
- **QEMU** (to give the new CPU something to run on): the [developer documentation](https://www.qemu.org/docs/master/devel/index.html) is an index; it covers new hardware models and TCG translation but has no "add a new target" page.

## 5. Mailing lists and contributing

- [Mailing lists](https://www.openbsd.org/mail.html): **tech@** is for technical discussion and for patches for new features and significant changes (this is where a new port goes); **ports@** is the ports tree; **arm@** and **ppc@** are the platform lists; **misc@** is general; `source-changes@` is the commit feed. There is no list for a new architecture.
- [Copyright Policy](https://www.openbsd.org/policy.html): see the short version above.
- "Preparing a Diff" is a section of [FAQ 5](https://www.openbsd.org/faq/faq5.html).

## What we could not find

- A single, current guide to porting OpenBSD; the 2005 slides are the nearest.
- Any text on adding an LLVM target to OpenBSD's base build.
- A written policy on accepting a new architecture: hardware, maintainer commitment, effect on the ports tree. The 2005 slides and the supported-platform criteria on plat.html are the nearest, and both assume real hardware that developers own.
- A first-hand write-up of the riscv64 or powerpc64 bring-up (only commit messages and the student report), a talk by Dale Rahn on arm64, or one by Jonathan Gray on riscv64 and LLVM.
- A `tech@` or `misc@` thread on bringing up a new architecture; the searches returned only release announcements.
- Not readable at the time: `config(8)`, `uvm(9)`, `cpu_startup(9)`, `fdt(9)` and `ddb(4)` (the manual server refused connections), the FreeBSD wiki's riscv history (blocked), and the OSDev wiki's porting page (403).

## What this means for the pdp64

Three things from OpenBSD's own rules bear on us. The port must be able to compile itself, which is already our plan (self-hosting inside OpenBSD on the emulator). The 2005 and plat.html material assumes real hardware owned by developers; an architecture that exists only as an emulator and an FPGA is outside what the written criteria describe, so that conversation with the developers needs to happen early. And the Apache 2 position needs an answer before we plan to upstream an LLVM back end.

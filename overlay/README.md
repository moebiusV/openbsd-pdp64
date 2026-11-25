# overlay/

New files of the port, at the paths they have in the OpenBSD tree: `overlay/sys/arch/pdp64/...`
is `sys/arch/pdp64/...`, `overlay/lib/libc/arch/pdp64/...` is `lib/libc/arch/pdp64/...`, and so on.
`tools/apply-overlay.sh` copies this directory over an OpenBSD checkout.

Only files that do not exist in OpenBSD belong here. A change to a file OpenBSD already has
(`share/mk/bsd.own.mk`, `Makefile.cross`, ...) is a patch in `../patches/`.

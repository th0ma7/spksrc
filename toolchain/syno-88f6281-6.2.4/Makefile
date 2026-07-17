TC_ARCH = 88f6281
TC_VERS = 6.2.4
TC_KERNEL = 2.6.32
TC_GLIBC = 2.15

# glibc 2.15 still keeps clock_gettime in librt (it moved into libc in 2.17), and
# ARMv5 has no native 64-bit atomics, so gcc calls into libatomic. Stated here
# rather than re-derived by every package: cups and ffmpeg4 currently test for
# ARMv5_ARCHS to add -lrt themselves. -latomic is ignored under a compiler that
# does not ship it, which is exactly the legacy case that neither has it nor
# needs it.
TC_EXTRA_LDFLAGS = -lrt -latomic

TC_DIST = 6281-gcc464_glibc215_88f6281-GPL
TC_DIST_SITE_PATH = toolchains%2Fdsm6.2.4

TC_TARGET = arm-marvell-linux-gnueabi
TC_SYSROOT = $(TC_TARGET)/libc

include ../../mk/spksrc.toolchain.mk

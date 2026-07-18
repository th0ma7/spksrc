TC_ARCH = 88f6281
TC_VERS = 5.2
TC_KERNEL = 2.6.32
TC_GLIBC = 2.15

TC_DIST = 6281-gcc464_glibc215_88f6281-GPL
TC_DIST_SITE_URL = https://github.com/SynoCommunity/spksrc/releases/download/
TC_DIST_SITE_PATH = toolchains%2Fdsm5.2

TC_TARGET = arm-marvell-linux-gnueabi
TC_SYSROOT = $(TC_TARGET)/libc
TC_LIBRARY = $(TC_SYSROOT)/usr/lib
# ARMv5 has no native atomics and glibc 2.15 keeps clock_gettime in librt --
# same as the DSM 6.2.4 88f6281 toolchain. -latomic is dropped automatically by
# tc-flags.mk when a selected compiler does not ship it.
TC_EXTRA_LDFLAGS = -lrt -latomic

include ../../mk/spksrc.toolchain.mk

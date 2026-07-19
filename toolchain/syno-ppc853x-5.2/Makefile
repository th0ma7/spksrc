TC_ARCH = ppc853x
TC_VERS = 5.2
TC_KERNEL = 2.6.32
TC_GLIBC = 2.8

TC_DIST = 853x-gcc4374_eglibc2874_qoriq-GPL
TC_DIST_SITE_URL = https://github.com/SynoCommunity/spksrc/releases/download/
TC_DIST_SITE_PATH = toolchains%2Fdsm5.2

TC_TARGET = powerpc-none-linux-gnuspe
TC_SYSROOT = $(TC_TARGET)
TC_INCLUDE = $(TC_SYSROOT)/include
TC_EXTRA_CFLAGS = -mcpu=8548 -mhard-float -mfloat-gprs=double
# PowerPC e500v2 (SPE) has no native 64-bit atomics, and glibc 2.8 keeps
# clock_gettime in librt -- the overlay gcc-8.5 emits __atomic_*_8 and
# clock_gettime calls that the link must resolve. Same as qoriq (also e500v2)
# plus -lrt for the very old glibc. -latomic is dropped automatically by
# tc-flags.mk when a selected compiler does not ship it.
TC_EXTRA_LDFLAGS = -lrt -latomic

include ../../mk/spksrc.toolchain.mk

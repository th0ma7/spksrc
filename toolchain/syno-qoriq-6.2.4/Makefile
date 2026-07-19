TC_ARCH = qoriq
TC_VERS = 6.2.4
TC_KERNEL = 2.6.32
TC_GLIBC = 2.20

TC_DIST = qoriq-gcc493_glibc220_hard_qoriq-GPL
TC_DIST_SITE_PATH = toolchains%2Fdsm6.2.4

TC_TARGET = powerpc-e500v2-linux-gnuspe
TC_SYSROOT = $(TC_TARGET)/sysroot
TC_EXTRA_CFLAGS = -mcpu=8548 -mhard-float -mfloat-gprs=double
# PowerPC e500v2 has no native 64-bit atomics, so gcc calls into libatomic. Stated
# here rather than re-derived by every package: ffmpeg8 currently tests for the arch
# by name to add --extra-libs=-latomic. Ignored under a compiler that does not ship
# libatomic -- which is also one that does not emit __atomic_* calls.
#
# No -lrt: glibc 2.20 already has clock_gettime in libc (it moved there in 2.17),
# which is exactly why cups lists OLD_PPC_ARCHS and not qoriq.
TC_EXTRA_LDFLAGS = -latomic

TC_EXTRA_RUSTFLAGS = -Ctarget-cpu=e500

include ../../mk/spksrc.toolchain.mk

ifneq ($(RUST_BUILD_TOOLCHAIN),1)
DEPENDS = toolchain/syno-$(TC_ARCH)-$(TC_VERS)-rust
else
POST_FIX_TARGET = qoriq_post_fix_target
endif

.PHONY: qoriq_post_fix_target
qoriq_post_fix_target:
	@cd $(WORK_DIR)/$(TC_TARGET)/bin ; \
	for gnutool in $$(ls -1); do \
	  [ ! -L "powerpc-linux-gnuspe-$${gnutool##*-}" ] && ln -sf $${gnutool} "powerpc-linux-gnuspe-$${gnutool##*-}" ; \
	  [ ! -L "powerpc-unknown-linux-gnuspe-$${gnutool##*-}" ] && ln -sf $${gnutool} "powerpc-unknown-linux-gnuspe-$${gnutool##*-}" ; \
	done

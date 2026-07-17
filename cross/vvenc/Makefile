PKG_NAME = vvenc
PKG_VERS = 1.14.0
PKG_EXT = tar.gz
PKG_DIST_NAME = v$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/fraunhoferhhi/vvenc/archive
PKG_DIST_FILE = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

HOMEPAGE = https://www.hhi.fraunhofer.de/en/departments/vca/technologies-and-solutions/h266-vvc.html
COMMENT  = VVenC, the Fraunhofer Versatile Video Encoder, is a fast and efficient software H.266/VVC encoder implementation
LICENSE  = BSD-3-Clause-Clear license

MIN_GCC_VERSION = 7.5
REQUIRED_MIN_SRM = 1.3

include ../../mk/spksrc.common.mk

# ARMv5 has no NEON at all, and neither ARMv7L (hi3535) nor the ARMv7 targets we
# build for can be relied on to have it, so vvenc's ARM SIMD path does not compile
# there ("'abs_hi' was not declared in this scope" out of arm/neon/MCTF_neon.cpp).
# ARMv8 keeps it: NEON is mandatory in that baseline.
#
# ARMv5 and ARMv7L were missing here simply because vvenc was never built for them
# -- they were excluded wholesale before this could show.
ifeq ($(findstring $(ARCH),$(ARMv5_ARCHS) $(ARMv7_ARCHS) $(ARMv7L_ARCHS)),$(ARCH))
CONFIGURE_ARGS += -DVVENC_ENABLE_ARM_SIMD=FALSE
endif

include ../../mk/spksrc.cross-cmake.mk

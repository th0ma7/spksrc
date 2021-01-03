PKG_NAME = mpfr
PKG_VERS = 4.1.0
PKG_EXT = tar.xz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://www.mpfr.org/$(PKG_NAME)-current
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/gmp

HOMEPAGE = https://www.mpfr.org/
COMMENT = The MPFR library is a C library for multiple-precision floating-point computations with correct rounding.
LICENSE = GPL v3.0

GNU_CONFIGURE = 1

include ../../mk/spksrc.cross-cc.mk

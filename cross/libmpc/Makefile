PKG_NAME = mpc
PKG_VERS = 1.2.1
PKG_EXT = tar.gz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = http://ftp.gnu.org/gnu/$(PKG_NAME)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/libmpfr

HOMEPAGE = http://www.multiprecision.org/mpc/
COMMENT = GNU MPC is a C library for the arithmetic of complex numbers with arbitrarily high precision and correct rounding of the result.
LICENSE = GPL v3.0

GNU_CONFIGURE = 1

include ../../mk/spksrc.cross-cc.mk

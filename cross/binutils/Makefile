PKG_NAME = binutils
PKG_VERS = 2.35
PKG_EXT = tar.lz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = http://ftp.gnu.org/gnu/$(PKG_NAME)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/gmp cross/libmpfr cross/libmpc

HOMEPAGE = https://www.gnu.org/software/binutils/
COMMENT = The GNU Binutils are a collection of binary tools.
LICENSE = GPL v3.0

GNU_CONFIGURE = 1

include ../../mk/spksrc.cross-cc.mk

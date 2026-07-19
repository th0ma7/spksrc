PKG_NAME = shine
PKG_VERS = 3.1.1
PKG_EXT = tar.gz
PKG_DIST_NAME = $(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://github.com/toots/shine/archive
PKG_DIST_FILE = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS =

HOMEPAGE = https://github.com/toots/shine
COMMENT  = Super fast fixed-point MP3 encoder.
LICENSE  = GPLv2

# shine calls __builtin_bswap16, which gcc 4.3.7 (ppc853x stock) lacks -- the link
# fails with "undefined reference to __builtin_bswap16". Present from gcc 4.6 on, so
# the capability check refuses only the very oldest stock gcc unless the overlay is
# used.
MIN_GCC_VERSION = 4.6

PRE_CONFIGURE_TARGET = shine_pre_configure
CONFIGURE_ARGS  = --includedir=$(INSTALL_DIR)/$(INSTALL_PREFIX)/include
CONFIGURE_ARGS += --disable-static

GNU_CONFIGURE = 1

include ../../mk/spksrc.cross-cc.mk

.PHONY: shine_pre_configure
shine_pre_configure: 
	@$(RUN) ./bootstrap

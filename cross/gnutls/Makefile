PKG_NAME = gnutls
PKG_VERS = 3.7.11
PKG_EXT = tar.xz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://gnupg.org/ftp/gcrypt/gnutls/v$(word 1,$(subst ., ,$(PKG_VERS))).$(word 2,$(subst ., ,$(PKG_VERS)))
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/libunistring cross/libtasn1 cross/nettle cross/zlib

HOMEPAGE = https://gnutls.org/
COMMENT  = GnuTLS is a secure communications library implementing the SSL, TLS and DTLS protocols and technologies around them.
LICENSE  = LGPLv2.1+

ifneq ($(strip $(GNUTLS_INCLUDE_EXECUTABLES)),1)
PLIST_TRANSFORM = sed -e '/bin:bin/d'
endif

GNU_CONFIGURE = 1
CONFIGURE_ARGS = --disable-doc
CONFIGURE_ARGS += --without-p11-kit
CONFIGURE_ARGS += --disable-nls
CONFIGURE_ARGS += gl_cv_func_gettimeofday_clobber=no
CONFIGURE_ARGS += gl_cv_func_signbit_gcc=no

include ../../mk/spksrc.cross-cc.mk

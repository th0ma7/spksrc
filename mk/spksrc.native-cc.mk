#
# Default NATIVE make programs
#

# Package dependent
URLS          = $(PKG_DIST_SITE)/$(PKG_DIST_NAME)
NAME          = $(PKG_NAME)
COOKIE_PREFIX = $(PKG_NAME)-
ifneq ($(PKG_DIST_FILE),)
LOCAL_FILE    = $(PKG_DIST_FILE)
else
LOCAL_FILE    = $(PKG_DIST_NAME)
endif
DIST_FILE     = $(DISTRIB_DIR)/$(LOCAL_FILE)
DIST_EXT      = $(PKG_EXT)
ARCH_SUFFIX  := -native

# Setup common directories
include ../../mk/spksrc.base/directories.mk

# Common makefiles
include ../../mk/spksrc.common.mk

#####

.NOTPARALLEL:

#####

include ../../mk/spksrc.native/env.mk

include ../../mk/spksrc.core/download.mk

include ../../mk/spksrc.base/depend.mk

include ../../mk/spksrc.base/status.mk

checksum: download
include ../../mk/spksrc.core/checksum.mk

extract: checksum depend status
include ../../mk/spksrc.core/extract.mk

patch: extract
include ../../mk/spksrc.core/patch.mk

configure: patch
include ../../mk/spksrc.core/configure.mk

compile: configure
include ../../mk/spksrc.core/compile.mk

install: compile
include ../../mk/spksrc.core/install.mk

###

.PHONY: cat_PLIST
cat_PLIST:
	@true

###

# Define _all as a real target that does the work
.PHONY: _all
_all: install

# all wraps _all with logging
.PHONY: all
.DEFAULT_GOAL := all

all:
	@mkdir -p $(WORK_DIR)
	$(call LOG_WRAPPED,_all)

####

### Include common rules
include ../../mk/spksrc.common-rules.mk

###

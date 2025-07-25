### Python wheel rules
#   Invoke make to make a wheel for a python module.
#   You can do some customization through python-cc.mk

# Python module targets
ifeq ($(strip $(CONFIGURE_TARGET)),)
CONFIGURE_TARGET = nop
endif
ifeq ($(strip $(COMPILE_TARGET)),)
COMPILE_TARGET = build_python_wheel_target
endif
ifeq ($(strip $(INSTALL_TARGET)),)
INSTALL_TARGET = install_python_wheel_target
endif
ifeq ($(strip $(POST_INSTALL_TARGET)),)
POST_INSTALL_TARGET = install_python_wheel
endif

# Resume with standard spksrc.cross-cc.mk
include ../../mk/spksrc.cross-cc.mk

# Define where is located the crossenv
CROSSENV_WHEEL_PATH = $(firstword $(wildcard $(WORK_DIR)/crossenv-$(or $(PKG_REAL_NAME),$(PKG_NAME))-$(PKG_VERS) $(WORK_DIR)/crossenv-$(or $(PKG_REAL_NAME),$(PKG_NAME)) $(WORK_DIR)/crossenv-default))

# If using spksrc.python.mk with PYTHON_STAGING_PREFIX defined
# then redirect STAGING_INSTALL_PREFIX so rust
# wheels can find openssl and other libraries
ifneq ($(wildcard $(PYTHON_STAGING_PREFIX)),)
STAGING_INSTALL_PREFIX := $(PYTHON_STAGING_PREFIX)
endif

### Prepare crossenv
prepare_crossenv:
	@$(MSG) $(MAKE) WHEEL_NAME=\"$(or $(PKG_REAL_NAME),$(PKG_NAME))\" WHEEL_VERSION=\"$(PKG_VERS)\" crossenv-$(ARCH)-$(TCVERSION)
	@MAKEFLAGS= $(MAKE) WHEEL_NAME="$(or $(PKG_REAL_NAME),$(PKG_NAME))" WHEEL_VERSION="$(PKG_VERS)" crossenv-$(ARCH)-$(TCVERSION) --no-print-directory

build_python_wheel_target: SHELL:=/bin/bash
build_python_wheel_target: prepare_crossenv
	$(foreach e,$(shell cat $(CROSSENV_WHEEL_PATH)/build/python-cc.mk),$(eval $(e)))
	@set -o pipefail; { \
	. $(CROSSENV) ; \
	if [ -e "$(CROSSENV)" ] ; then \
	   export PATH=$${PATH}:$(CROSSENV_PATH)/build/bin ; \
	   $(MSG) "crossenv: [$(CROSSENV)]" ; \
	   $(MSG) "python: [$$(which cross-python)]" ; \
	   $(MSG) "maturin: [$$(which maturin)]" ; \
	else \
	   echo "ERROR: crossenv not found!" ; \
	   exit 2 ; \
	fi ; \
	$(MSG) _PYTHON_HOST_PLATFORM=$(TC_TARGET) $$(which cross-python) -m build $(BUILD_ARGS) \
	          --no-isolation \
	          --wheel $(WHEELS_BUILD_ARGS) \
	          --outdir $(WHEELHOUSE) ; \
	$(RUN) _PYTHON_HOST_PLATFORM=$(TC_TARGET) $$(which cross-python) -m build $(BUILD_ARGS) \
	          --no-isolation \
	          --wheel $(WHEELS_BUILD_ARGS) \
	          --outdir $(WHEELHOUSE) ; \
	} > >(tee --append $(WHEEL_LOG)) 2>&1 ; [ $${PIPESTATUS[0]} -eq 0 ] || false

install_python_wheel_target: SHELL:=/bin/bash
install_python_wheel_target:
	@set -o pipefail; { \
	$(MSG) $(MAKE) REQUIREMENT=\"$(or $(PKG_REAL_NAME),$(PKG_NAME))==$(PKG_VERS)\" \
	               WHEEL_NAME=\"$(or $(PKG_REAL_NAME),$(PKG_NAME))\" \
	               WHEEL_VERSION=\"$(PKG_VERS)\" \
	               WHEEL_TYPE=\"cross\" \
	               wheel_install ; \
	MAKEFLAGS= $(MAKE) REQUIREMENT="$(or $(PKG_REAL_NAME),$(PKG_NAME))==$(PKG_VERS)" \
	                   WHEEL_NAME="$(or $(PKG_REAL_NAME),$(PKG_NAME))" \
	                   WHEEL_VERSION="$(PKG_VERS)" \
	                   WHEEL_TYPE="cross" \
	                   --no-print-directory \
	                   wheel_install ; \
	} > >(tee --append $(WHEEL_LOG)) 2>&1 ; [ $${PIPESTATUS[0]} -eq 0 ] || false

###

# Use crossenv
include ../../mk/spksrc.crossenv.mk

## python wheel specific configurations
include ../../mk/spksrc.wheel-env.mk

## install wheel specific routines
include ../../mk/spksrc.wheel-install.mk

###

post_compile_target: $(COMPILE_TARGET)

# Call spksrc.compile.mk cookie creation recipe
ifeq ($(wildcard $(COMPILE_COOKIE)),)
compile: $(COMPILE_COOKIE)
endif

###

post_install_target: $(INSTALL_TARGET)

# Call spksrc.install.mk cookie creation recipe
ifeq ($(wildcard $(INSTALL_COOKIE)),)
install: $(INSTALL_COOKIE)

$(INSTALL_COOKIE):
	$(create_target_dir)
	@touch -f $@
endif

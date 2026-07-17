###############################################################################
# spksrc.toolchain/tc-flags.mk
#
# Defines compiler, linker, and language tool defaults for the toolchain.
#
# This file:
#  - derives missing toolchain paths (prefix, include, library)
#  - detects optional language support (Fortran)
#  - declares tool mappings (gcc, g++, ld, ar, gfortran, etc.)
#  - assembles default build flags for C, C++, Fortran, and Rust
#
# Variables:
#  TC_PREFIX       : Toolchain binary prefix (<target>-)
#  TC_INCLUDE      : Toolchain include directory (sysroot)
#  TC_LIBRARY      : Toolchain library directory (sysroot)
#  TC_HAS_FORTRAN  : Indicates availability of gfortran
#  TOOLS           : Logical-to-compiler tool mapping
#
# Flags defined:
#  CFLAGS / CPPFLAGS / CXXFLAGS / FFLAGS
#  LDFLAGS
#  RUSTFLAGS
#
# Notes:
#  - Fortran support is inferred from TC_VERS and ARCH, not from filesystem.
#  - Flags include both toolchain sysroot and package install paths.
#
###############################################################################

ifeq ($(strip $(TC_PREFIX)),)
TC_PREFIX = $(TC_TARGET)-
endif

ifeq ($(strip $(TC_INCLUDE)),)
TC_INCLUDE = $(TC_SYSROOT)/usr/include
endif

ifeq ($(strip $(TC_LIBRARY)),)
TC_LIBRARY = $(TC_SYSROOT)/lib
endif

# Does this toolchain provide gfortran? Look, rather than tabulate.
#
# This was a DSM/arch table, justified by "we can't check whether gfortran exists,
# because toolchain is not yet extracted". True at parse time -- but TOOLS is only
# ever expanded inside the tc_vars recipes, and by then extraction has happened
# (tcvars runs after rustc, which depends on patch -> extract). Deferring the
# check with a lazy '=' is all it takes.
#
# Two reasons the table had to go. A gcc overlay (native/gcc8) is built with
# fortran enabled, so it brings gfortran to toolchains no table would list: armv5
# now has arm-marvell-linux-gnueabi-gfortran-8.5, while the table said its
# DSM/arch pair has none. And the table answered differently depending on the
# caller -- its 6.2.4 branch tested $(findstring $(ARCH),$(x64_ARCHS)) against
# $(ARCH), which an unset ARCH satisfies vacuously, so every 6.2.4 toolchain
# claimed fortran from the toolchain context and only x64 did from a package.
# Looks for the exact binary this build will use, suffix included: a bare
# gfortran* glob would match the overlay's gfortran-8.5 and answer yes under
# LEGACY_TOOLCHAIN, where the stock armv5 toolchain has no gfortran at all.
# TC_GCC_SUFFIX is defined later (tc_vars.mk); lazy expansion makes that fine.
TC_HAS_FORTRAN = $(if $(wildcard $(TC_WORK_DIR)/$(TC_TARGET)/bin/$(TC_PREFIX)gfortran$(TC_GCC_SUFFIX)),1)

# $(if ...) rather than a parse-time ifneq, to keep TC_HAS_FORTRAN lazy.
TOOLS = ld ldshared:"gcc -shared" cpp nm cc:gcc as ranlib cxx:g++ ar strip objdump objcopy readelf$(if $(strip $(TC_HAS_FORTRAN)), fc:gfortran)

####
# Define regular build flags

CFLAGS += -I$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_INCLUDE)) $(TC_EXTRA_CFLAGS)
CFLAGS += -I$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/include)

CPPFLAGS += -I$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_INCLUDE)) $(TC_EXTRA_CFLAGS)
CPPFLAGS += -I$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/include)

CXXFLAGS += -I$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_INCLUDE)) $(TC_EXTRA_CFLAGS)
CXXFLAGS += -I$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/include)

ifneq ($(strip $(TC_HAS_FORTRAN)),)
FFLAGS += -I$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_INCLUDE)) $(TC_EXTRA_FFLAGS)
FFLAGS += -I$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/include)
endif

LDFLAGS += -L$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_LIBRARY)) $(TC_EXTRA_CFLAGS)
LDFLAGS += -L$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/lib)
LDFLAGS += -Wl,--rpath-link,$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/lib)
LDFLAGS += -Wl,--rpath,$(abspath $(INSTALL_PREFIX)/lib)

RUSTFLAGS += -Clink-arg=-L$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_LIBRARY))
RUSTFLAGS += -Clink-arg=-L$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/lib)
RUSTFLAGS += -Clink-arg=-Wl,--rpath-link,$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/lib)
RUSTFLAGS += -Clink-arg=-Wl,--rpath,$(abspath $(INSTALL_PREFIX)/lib)

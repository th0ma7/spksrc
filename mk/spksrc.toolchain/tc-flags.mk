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

# Does the SELECTED compiler ship libatomic? Ask it, rather than tabulate.
#
# A target without native 64-bit atomics (ARMv5, PowerPC e500v2) makes gcc emit
# calls into libatomic, which the link then has to resolve. But the library only
# ships from gcc 4.7 on, and handing -latomic to an older gcc is fatal -- "cannot
# find -latomic" -- so a toolchain cannot just declare the flag and be done:
# whether it applies depends on which compiler LEGACY_TOOLCHAIN selected, not on
# the target alone.
#
# Availability is the exact criterion here, not a lucky proxy: a gcc old enough
# to lack libatomic also predates the __atomic_* builtins, emits __sync_*
# instead, and therefore never needs the library. One question answers both, and
# it answers for whichever compiler was actually picked. Lazy on purpose --
# TC_GCC_SUFFIX comes from tc_vars.mk, later.
TC_HAS_LIBATOMIC = $(if $(filter /%,$(shell $(TC_WORK_DIR)/$(TC_TARGET)/bin/$(TC_PREFIX)gcc$(TC_GCC_SUFFIX) -print-file-name=libatomic.so 2>/dev/null)),1)

# Link flags a TOOLCHAIN declares for itself, beside TC_EXTRA_CFLAGS: what the
# target needs from the linker, stated once, where it is known.
#
# Packages carry this knowledge today, as arch lists -- cups and ffmpeg4
# enumerate ARMv5_ARCHS/OLD_PPC_ARCHS to add -lrt (those are exactly the
# toolchains whose glibc predates 2.17, when clock_gettime moved into libc),
# ffmpeg8 names qoriq to add -latomic, and flac gives up and adds -lrt
# everywhere. That is the same "name where it breaks instead of why" that
# MIN_GCC_VERSION replaces on the capability side.
#
# -latomic is dropped when the selected compiler does not ship it, so a toolchain
# can declare it once and legacy builds keep linking exactly as before.
TC_EXTRA_LDFLAGS_SELECTED = $(if $(TC_HAS_LIBATOMIC),$(TC_EXTRA_LDFLAGS),$(filter-out -latomic,$(TC_EXTRA_LDFLAGS)))

####
# Define regular build flags

CFLAGS += -I$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_INCLUDE)) $(TC_EXTRA_CFLAGS)
CFLAGS += -I$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/include)

CPPFLAGS += -I$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_INCLUDE)) $(TC_EXTRA_CFLAGS)
CPPFLAGS += -I$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/include)

CXXFLAGS += -I$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_INCLUDE)) $(TC_EXTRA_CFLAGS)
CXXFLAGS += -I$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/include)

# $(if ...) rather than a parse-time ifneq: TC_HAS_FORTRAN is lazy (it looks for
# the binary), and at parse time the toolchain may not be extracted yet.
FFLAGS += $(if $(strip $(TC_HAS_FORTRAN)),-I$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_INCLUDE)) $(TC_EXTRA_FFLAGS))
FFLAGS += $(if $(strip $(TC_HAS_FORTRAN)),-I$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/include))

# The sysroot -L below also carries the toolchain's STOCK libstdc++, and ld
# searches an explicit -L before the compiler's own directories. So with a gcc
# overlay selected, ANY package linking C++ silently picks up the stock libstdc++
# and dies on symbols the newer compiler emits -- std::__cxx11::basic_string (the
# gcc 5 ABI), or operator delete(void*, size_t) (C++14 sized delete). It is not
# the package's fault and no package can work around it: the framework hands every
# build that -L. Put the overlay's own runtime directory ahead of it.
#
# Only when an overlay is actually selected (TC_GCC_SUFFIX non-empty): under
# LEGACY_TOOLCHAIN the stock libstdc++ is the correct one. Lazy on purpose --
# TC_GCC_SUFFIX is defined later, in tc_vars.mk.
TC_OVERLAY_LIBDIR = $(if $(strip $(TC_GCC_SUFFIX)),$(dir $(firstword $(wildcard $(TC_WORK_DIR)/$(TC_TARGET)/lib/gcc/$(TC_TARGET)/*/libstdc++.a))))
LDFLAGS += $(if $(TC_OVERLAY_LIBDIR),-L$(TC_OVERLAY_LIBDIR))
# The -L above resolves libstdc++ for a DIRECT link. But when a shared library the
# build links against (libchromaprint.so) has its own NEEDED libstdc++.so.6, ld
# resolves that transitively through --rpath-link, not -L. The overlay's libstdc++
# lives outside every default rpath-link path, so a C program linking a C++ shared
# library -- exactly ffmpeg's chromaprint probe -- fails on the string/CXXABI
# symbols the .so pulls from libstdc++. Put the overlay dir on rpath-link too.
#
# patsubst rather than $(if ...): the flag itself contains commas
# (-Wl,--rpath-link,DIR) and $(if) reads those as its own argument separators,
# which silently truncated this to a bare "-Wl". patsubst yields nothing when
# TC_OVERLAY_LIBDIR is empty and the full flag when it is set.
_tc_comma := ,
LDFLAGS += $(patsubst %,-Wl$(_tc_comma)--rpath-link$(_tc_comma)%,$(TC_OVERLAY_LIBDIR))
LDFLAGS += -L$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_LIBRARY)) $(TC_EXTRA_CFLAGS)
LDFLAGS += $(TC_EXTRA_LDFLAGS_SELECTED)
LDFLAGS += -L$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/lib)
LDFLAGS += -Wl,--rpath-link,$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/lib)
LDFLAGS += -Wl,--rpath,$(abspath $(INSTALL_PREFIX)/lib)

RUSTFLAGS += -Clink-arg=-L$(abspath $(TC_WORK_DIR)/$(TC_TARGET)/$(TC_LIBRARY))
RUSTFLAGS += -Clink-arg=-L$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/lib)
RUSTFLAGS += -Clink-arg=-Wl,--rpath-link,$(abspath $(INSTALL_DIR)/$(INSTALL_PREFIX)/lib)
RUSTFLAGS += -Clink-arg=-Wl,--rpath,$(abspath $(INSTALL_PREFIX)/lib)

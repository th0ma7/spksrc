###############################################################################
# spksrc.common/tc-capability.mk
#
# Lets a package declare what it NEEDS instead of enumerating where it happens
# to work today:
#
#   MIN_GLIBC_VERSION = 2.20    needs glibc 2.20 or newer
#   MIN_GCC_VERSION   = 8       needs gcc 8 or newer
#
# The two are deliberately NOT symmetric, and that asymmetry is the whole point:
#
#   glibc is a runtime floor. Nothing can lift it -- linking against a newer one
#         produces binaries that will not start on the NAS -- so an arch below
#         MIN_GLIBC_VERSION is genuinely unsupported.
#
#   gcc   is not. A gcc overlay (toolchain/syno-<arch>-<vers>-gcc8) rebuilds a
#         newer compiler against the same sysroot, so an arch whose stock gcc is
#         too old is still supported when an overlay satisfies the requirement --
#         and the overlay is then selected automatically. The package asked for a
#         capability; picking the toolchain that provides it is the framework's
#         job.
#
# This replaces the classic "UNSUPPORTED_ARCHS = <list>" for capability reasons.
# A hardcoded list cannot know that an overlay just lifted the constraint, and it
# says where a package fails rather than why.
#
# Everything is resolved WITHOUT building the toolchain, from what is already on
# disk: the stock gcc and glibc are encoded in the toolchain's own Makefile, and
# an overlay announces itself by existing. That matters -- reading the gcc back
# from a generated tc_vars.mk would make the answer depend on how the toolchain
# happened to be built last, so two clones could disagree.
#
# Variables provided (per ARCH/TCVERSION):
#   TC_STOCK_GCC     the toolchain's own gcc      (from TC_DIST: gcc493 -> 4.9.3)
#   TC_STOCK_GLIBC   the toolchain's glibc        (from TC_GLIBC)
#   TC_OVERLAY_GCC   gcc an overlay could provide (empty when there is none)
#   TC_GCC_EFFECTIVE the gcc this build will actually use
###############################################################################

# Was the compiler choice made explicitly (package Makefile, local.mk, command
# line), or is it still just the default? Captured with $(origin) BEFORE any
# default is applied, because '?=' cannot tell the two apart afterwards -- and
# MIN_GCC_VERSION must be able to lift the default while still yielding to an
# explicit choice.
_TC_LEGACY_EXPLICIT := $(if $(filter undefined default,$(origin LEGACY_TOOLCHAIN)),,1)

ifneq ($(strip $(ARCH))$(strip $(TCVERSION)),)

_TC_CAP_MK := $(BASEDIR)/toolchain/syno-$(ARCH)-$(TCVERSION)/Makefile

# gcc493 -> 4.9.3, gcc750 -> 7.5.0, and a future gcc1230 -> 12.3.0: the last two
# digits are minor and patch, whatever is left is the major.
TC_STOCK_GCC := $(shell sed -n 's/^TC_DIST *= *//p' $(_TC_CAP_MK) 2>/dev/null | \
                  sed -n 's/.*-gcc\([0-9]\+\)_.*/\1/p' | \
                  sed -E 's/^([0-9]+)([0-9])([0-9])$$/\1.\2.\3/')
TC_STOCK_GLIBC := $(shell sed -n 's/^TC_GLIBC *= *//p' $(_TC_CAP_MK) 2>/dev/null)

# An overlay package existing is the declaration that this gcc is available here.
TC_OVERLAY_GCC := $(if $(wildcard $(BASEDIR)/toolchain/syno-$(ARCH)-$(TCVERSION)-gcc8),8.5)

# ---- glibc: a floor, so too old means unsupported ---------------------------
ifneq ($(strip $(MIN_GLIBC_VERSION)),)
ifneq ($(strip $(TC_STOCK_GLIBC)),)
ifeq ($(call version_ge,$(TC_STOCK_GLIBC),$(MIN_GLIBC_VERSION)),)
TC_CAPABILITY_UNSUPPORTED := glibc $(TC_STOCK_GLIBC) < $(MIN_GLIBC_VERSION) (a runtime floor: no toolchain can lift it)
endif
endif
endif

# ---- gcc: liftable by an overlay --------------------------------------------
ifneq ($(strip $(MIN_GCC_VERSION)),)
ifneq ($(strip $(TC_STOCK_GCC)),)
ifeq ($(call version_ge,$(TC_STOCK_GCC),$(MIN_GCC_VERSION)),)
# stock is too old -- can an overlay satisfy it?
ifeq ($(call version_ge,$(TC_OVERLAY_GCC),$(MIN_GCC_VERSION)),)
TC_CAPABILITY_UNSUPPORTED := gcc $(TC_STOCK_GCC) < $(MIN_GCC_VERSION)$(if $(TC_OVERLAY_GCC), and the $(TC_OVERLAY_GCC) overlay is not enough, and no gcc overlay exists here)
else ifeq ($(_TC_LEGACY_EXPLICIT),)
# The package asked for a capability an overlay provides, and nobody said
# otherwise: select it. Picking the toolchain that satisfies a stated requirement
# is the framework's job -- the package should not have to know overlays exist.
# An explicit LEGACY_TOOLCHAIN still wins (it is left untouched here).
LEGACY_TOOLCHAIN := 0
endif
endif
endif
endif

# Default: the toolchain's stock gcc, so an installed overlay stays inactive.
# Applied last, so MIN_GCC_VERSION above can lift it. Defined here rather than in
# tc_vars.mk so the package side and the toolchain side cannot disagree about
# what "default" means.
LEGACY_TOOLCHAIN ?= 1

# The gcc this build will actually use, known before anything is built. Package
# logic should branch on this rather than on the TC_GCC that tc_vars reports back
# after the fact -- that one depends on how the toolchain happened to be built.
TC_GCC_EFFECTIVE := $(if $(filter 1 on ON,$(strip $(LEGACY_TOOLCHAIN))),$(TC_STOCK_GCC),$(or $(strip $(TC_GCC_VERSION)),$(TC_OVERLAY_GCC),$(TC_STOCK_GCC)))

else
# No ARCH/TCVERSION (toolchain build, noarch, ...): only the default applies.
LEGACY_TOOLCHAIN ?= 1
endif

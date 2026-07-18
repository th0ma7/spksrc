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

# Decode the gcc token of a TC_DIST. Three real shapes exist in the tree:
#
#   gcc493  gcc750  gcc850     3 digits -> 4.9.3  7.5.0  8.5.0
#   gcc1030 gcc1220            4 digits -> 10.3.0 12.2.0     (two-digit major)
#   gcc4374                    4 digits -> 4.3.7            (legacy DSM 5.2 form,
#                                                            trailing build digit)
#
# The 4-digit case is ambiguous, and getting it wrong is not cosmetic: reading
# gcc4374 as "43.7.4" makes an arch stuck on gcc 4.3.7 satisfy every conceivable
# MIN_GCC_VERSION -- the guard would wave through exactly what it exists to stop.
# Disambiguated on the major: 10 and 12 are plausible gcc majors, 43 is not.
# Anything up to 20 is treated as a major, which leaves room for gcc to keep
# counting for a while.
TC_STOCK_GCC := $(shell sed -n 's/^TC_DIST *= *//p' $(_TC_CAP_MK) 2>/dev/null | \
                  sed -n 's/.*-gcc\([0-9]\+\)[_-].*/\1/p' | \
                  awk '{ n=length($$0); \
                         if (n==3) { printf "%s.%s.%s", substr($$0,1,1), substr($$0,2,1), substr($$0,3,1) } \
                         else if (n==4 && substr($$0,1,2)+0 <= 20) { printf "%s.%s.%s", substr($$0,1,2), substr($$0,3,1), substr($$0,4,1) } \
                         else if (n>=4) { printf "%s.%s.%s", substr($$0,1,1), substr($$0,2,1), substr($$0,3,1) } }')
TC_STOCK_GLIBC := $(shell sed -n 's/^TC_GLIBC *= *//p' $(_TC_CAP_MK) 2>/dev/null)

# The Linux kernel headers the toolchain ships (its sysroot). Read here, statically
# from the toolchain Makefile, for the same reason as glibc: a package gating on it
# (ffmpeg's V4L2 multiplanar API needs 3.1) must get a reliable answer, not the empty
# string a not-yet-generated tc_vars.mk would give -- which version_lt reads as
# "older than everything".
TC_STOCK_KERNEL := $(shell sed -n 's/^TC_KERNEL *= *//p' $(_TC_CAP_MK) 2>/dev/null)

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
# Step 1: pick the compiler. If the stock gcc is too old but an overlay would do,
# and nobody said otherwise, select it -- the package declares a need, and picking
# a toolchain that satisfies it is the framework's job, not the package's. An
# explicit LEGACY_TOOLCHAIN is left untouched here and therefore wins.
ifneq ($(strip $(MIN_GCC_VERSION)),)
ifneq ($(strip $(TC_STOCK_GCC)),)
ifeq ($(call version_ge,$(TC_STOCK_GCC),$(MIN_GCC_VERSION)),)
ifneq ($(call version_ge,$(TC_OVERLAY_GCC),$(MIN_GCC_VERSION)),)
ifeq ($(_TC_LEGACY_EXPLICIT),)
LEGACY_TOOLCHAIN := 0
endif
endif
endif
endif
endif

# Default: the toolchain's stock gcc, so an installed overlay stays inactive.
# Applied after step 1, so MIN_GCC_VERSION can lift it. Defined here rather than
# in tc_vars.mk so the package side and the toolchain side cannot disagree about
# what "default" means.
LEGACY_TOOLCHAIN ?= 1

# The gcc this build will actually use, known before anything is built. Package
# logic should branch on this rather than on the TC_GCC that tc_vars reports back
# after the fact -- that one depends on how the toolchain happened to be built.
TC_GCC_EFFECTIVE := $(if $(filter 1 on ON,$(strip $(LEGACY_TOOLCHAIN))),$(TC_STOCK_GCC),$(or $(strip $(TC_GCC_VERSION)),$(TC_OVERLAY_GCC),$(TC_STOCK_GCC)))

# Step 2: judge the compiler that was actually picked, not the one that could
# have been. Checking "could an overlay satisfy this?" would wave through a build
# that then compiles with the stock gcc anyway -- forced there by an explicit
# LEGACY_TOOLCHAIN=1, or by a TC_GCC_VERSION pinned too low. That is exactly the
# failure this variable exists to prevent: without it the build dies much later,
# deep inside a source file, with a diagnostic that names neither the toolchain
# nor the requirement.
# Plain ifeq rather than a nested $(if): the messages contain commas, and make
# reads those as argument separators.
ifneq ($(strip $(MIN_GCC_VERSION)),)
ifneq ($(strip $(TC_GCC_EFFECTIVE)),)
ifeq ($(call version_ge,$(TC_GCC_EFFECTIVE),$(MIN_GCC_VERSION)),)

ifneq ($(call version_ge,$(TC_OVERLAY_GCC),$(MIN_GCC_VERSION)),)
TC_CAPABILITY_UNSUPPORTED := gcc $(TC_GCC_EFFECTIVE) < $(MIN_GCC_VERSION); the $(TC_OVERLAY_GCC) overlay would satisfy it but the stock gcc was forced (LEGACY_TOOLCHAIN)
else ifneq ($(strip $(TC_OVERLAY_GCC)),)
TC_CAPABILITY_UNSUPPORTED := gcc $(TC_GCC_EFFECTIVE) < $(MIN_GCC_VERSION); the $(TC_OVERLAY_GCC) overlay is not enough either
else
TC_CAPABILITY_UNSUPPORTED := gcc $(TC_GCC_EFFECTIVE) < $(MIN_GCC_VERSION); no gcc overlay exists for this toolchain
endif

endif
endif
endif

# ---- one compiler per chain, and the record has to stay honest --------------
#
# A build resolves its compiler once, at the root, and every dependency inherits
# it: WORK_DIR is guarded by ifndef in directories.mk and handed down through the
# environment by depend.mk, so the whole tree shares one work dir, one tc_vars and
# one libstdc++. That is deliberate. A chain that mixed compilers could package
# two copies of a runtime library, or the copy that does not match the binary
# asking for it -- and a dependency built by gcc 8.5 asks for GLIBCXX_3.4.21 from
# a root linked against 3.4.16.
#
# The cost of freezing it is that a stale or contradicted record is invisible.
# Two divergences pass in silence today, and one comparison catches both:
#
#   - the mode changed since this work dir was made (a Makefile edited, another
#     LEGACY_TOOLCHAIN on the command line). tc_vars keeps the old compiler and
#     the build quietly keeps using it.
#   - a dependency declares the opposite of the chain it is pulled into. Its
#     declaration is dropped without a word: cross/zlib carrying
#     LEGACY_TOOLCHAIN=1, built under a chain on the overlay, comes out compiled
#     by gcc 8.5.
#
# An error, not a silent regeneration: the mode also invalidates what is already
# built here -- install/ holds libraries from the previous compiler -- so nothing
# short of a clean makes the tree coherent again. The message has to say so.
#
# Skipped in the toolchain context: that is where tc_vars is generated, and a
# generator must not be stopped by the file it is about to overwrite.
#
# Also skipped once the capability check above has already refused this arch. Both
# fire on the same mistake -- MIN_GCC_VERSION unmet because the stock gcc was
# forced -- but that one names the cause while this one only reports that the work
# dir disagrees, which is its consequence. Reporting a symptom over a known cause
# helps nobody.
ifeq ($(strip $(TC_CAPABILITY_UNSUPPORTED)),)
ifneq ($(notdir $(abspath $(CURDIR)/..)),toolchain)
_TC_VARS_RECORDED := $(wildcard $(WORK_DIR)/tc_vars.mk)
ifneq ($(_TC_VARS_RECORDED),)

_TC_SUFFIX_IS   := $(strip $(shell sed -n 's/^TC_GCC_SUFFIX *:= *//p' $(_TC_VARS_RECORDED) 2>/dev/null))
_TC_SUFFIX_WANT := $(if $(filter 1 on ON,$(strip $(LEGACY_TOOLCHAIN))),,$(if $(strip $(TC_GCC_VERSION)),-$(strip $(TC_GCC_VERSION)),$(if $(strip $(TC_OVERLAY_GCC)),-$(strip $(TC_OVERLAY_GCC)))))

ifneq ($(_TC_SUFFIX_IS),$(_TC_SUFFIX_WANT))
$(error $(NAME) asks for $(if $(_TC_SUFFIX_WANT),gcc$(_TC_SUFFIX_WANT),the stock gcc) but $(WORK_DIR) was built with $(if $(_TC_SUFFIX_IS),gcc$(_TC_SUFFIX_IS),the stock gcc). One compiler is fixed for a whole dependency chain: mixing them packages runtime libraries that do not match the binaries asking for them. Run 'make clean' to rebuild this chain in one mode -- or align the declaration with it)
endif

endif
endif
endif

else
# No ARCH/TCVERSION (toolchain build, noarch, ...): only the default applies.
LEGACY_TOOLCHAIN ?= 1
endif

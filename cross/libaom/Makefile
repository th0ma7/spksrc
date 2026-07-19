PKG_NAME = libaom-virtual

OPTIONAL_DEPENDS  = cross/libaom-latest
OPTIONAL_DEPENDS += cross/libaom-3.8

UNSUPPORTED_ARCHS = $(ARMv5_ARCHS) $(OLD_PPC_ARCHS)

include ../../mk/spksrc.common.mk

# libaom-latest needs gcc >= 7.5, DSM >= 7.0 (REQUIRED_MIN_DSM) and excludes
# comcerto2k. The virtual's choice has to match what the child actually supports, or
# the pick fails downstream: the overlay gives a DSM 6.2.4 arch gcc 8.5, the bare
# gcc gate then routes it to libaom-latest, which refuses it on REQUIRED_MIN_DSM.
# Route anything libaom-latest cannot serve to libaom-3.8 -- same shape as the libvpx
# selector, kept in step with libaom-latest's own constraints.
ifeq ($(findstring $(ARCH),comcerto2k),$(ARCH))
DEPENDS = cross/libaom-3.8
else ifeq ($(call version_lt, $(TCVERSION), 7.0),1)
DEPENDS = cross/libaom-3.8
else ifeq ($(call version_ge, $(TC_GCC_EFFECTIVE), 7.5),1)
DEPENDS = cross/libaom-latest
else
DEPENDS = cross/libaom-3.8
endif

include ../../mk/spksrc.cross-virtual.mk

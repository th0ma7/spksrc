PKG_NAME = libaom-virtual

OPTIONAL_DEPENDS  = cross/libaom-latest
OPTIONAL_DEPENDS += cross/libaom-3.8

UNSUPPORTED_ARCHS = $(ARMv5_ARCHS) $(OLD_PPC_ARCHS)

include ../../mk/spksrc.common.mk

# gcc >= 7.5
# libaom-latest excludes comcerto2k (UNSUPPORTED_ARCHS). The gcc gate below picks it
# whenever the compiler is new enough, and that used to imply "not comcerto2k"
# because comcerto2k was stuck on gcc 4.9.3. The overlay breaks the implication:
# comcerto2k now has gcc 8.5, so the gate routes it to a libaom that refuses it.
# Compiler version and arch support are separate questions; comcerto2k takes 3.8
# regardless of how new the compiler is -- the same shape as the libvpx selector.
ifeq ($(findstring $(ARCH),comcerto2k),$(ARCH))
DEPENDS = cross/libaom-3.8
else ifeq ($(call version_ge, $(TC_GCC), 7.5),1)
DEPENDS = cross/libaom-latest
else
DEPENDS = cross/libaom-3.8
endif

include ../../mk/spksrc.cross-virtual.mk

PKG_NAME = libvpx-virtual

OPTIONAL_DEPENDS  = cross/libvpx-latest
OPTIONAL_DEPENDS += cross/libvpx-1.14

include ../../mk/spksrc.common.mk

# GCC >= 5 (DSM >= 7.0)
# libvpx-latest (1.16) offers only armv7 and armv8 ARM targets upstream -- it
# dropped ARMv5. The gcc gate below picks it whenever the compiler is new enough,
# and that used to imply "not ARMv5" because ARMv5 was stuck on gcc 4.6. The overlay
# breaks that: ARMv5 now has gcc 8.5, so the gate would route it to a libvpx that
# has no target for it (configure guesses the x86_64 host and passes -m64 to the ARM
# compiler). Compiler version and ISA support are separate questions; the overlay
# just made the proxy between them wrong. ARMv5 and PowerPC take 1.14, which still
# has a --target=generic-gnu case for both -- libvpx-latest offers only armv7/armv8/
# x86 targets -- regardless of how new the compiler is.
ifeq ($(findstring $(ARCH),$(ARMv5_ARCHS) $(PPC_ARCHS)),$(ARCH))
DEPENDS = cross/libvpx-1.14
else ifeq ($(call version_ge, $(TC_GCC_EFFECTIVE), 7.5),1)
DEPENDS = cross/libvpx-latest
else
DEPENDS = cross/libvpx-1.14
endif

include ../../mk/spksrc.cross-virtual.mk

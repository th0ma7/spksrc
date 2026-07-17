###############################################################################
# spksrc.rules/status.mk
#
# Build status tracking: a placeholder target that records already-processed
# dependencies while walking the dependency tree, to avoid repeating them in
# $(STATUS_LOG).
#
# Targets are executed in the following order:
#  pre_status_target    (override with PRE_STATUS_TARGET)
#  status_target        (override with STATUS_TARGET)
#  post_status_target   (override with POST_STATUS_TARGET)
###############################################################################

STATUS_COOKIE = $(WORK_DIR)/.$(COOKIE_PREFIX)status_done

ifeq ($(strip $(PRE_STATUS_TARGET)),)
PRE_STATUS_TARGET = pre_status_target
else
$(PRE_STATUS_TARGET): status_msg
endif
ifeq ($(strip $(STATUS_TARGET)),)
STATUS_TARGET = status_target
else
$(STATUS_TARGET): $(PRE_STATUS_TARGET)
endif
ifeq ($(strip $(POST_STATUS_TARGET)),)
POST_STATUS_TARGET = post_status_target
else
$(POST_STATUS_TARGET): $(STATUS_TARGET)
endif

.PHONY: status
.PHONY: $(PRE_STATUS_TARGET) $(STATUS_TARGET) $(POST_STATUS_TARGET)

pre_status_target:

# "GCC: <version> (overlay|legacy)" naming the compiler this build actually used.
#
# Stated in the positive for both modes rather than only marking the overlay: a
# reader should not have to infer "legacy" from the absence of a field. Reading a
# dependency chain then shows, line by line, which compiler each one got -- and
# since the whole chain is pinned to one, an odd line out is a bug worth seeing.
#
# TC_GCC is what the compiler reported for itself (-dumpversion) in the generated
# tc_vars.mk, so it is right for either mode; TC_GCC_SUFFIX is non-empty precisely
# when an overlay was selected, which makes it the mode. The field disappears where
# no cross compiler is involved (native, toolchain), rather than printing a blank.
#
# _status_comma: a literal comma cannot be written inside $(if ...) -- make reads it
# as an argument separator.
_status_comma := ,
STATUS_GCC = $(if $(strip $(TC_GCC)),GCC: $(strip $(TC_GCC)) ($(if $(strip $(TC_GCC_SUFFIX)),overlay,legacy))$(_status_comma) )

status_target:  $(PRE_STATUS_TARGET)
ifeq ($(notdir $(abspath $(CURDIR)/..)),native)
	@$(MSG) $$(printf "%s MAKELEVEL: %02d, PARALLEL_MAKE: %s, %sARCH: %s, NAME: %s\n" "$$(date +%Y%m%d-%H%M%S)" $(MAKELEVEL) "$(PARALLEL_MAKE)" "$(STATUS_GCC)" "$(STATUS_ARCH)" "$(NAME)") | tee --append $(STATUS_LOG)
else ifeq ($(notdir $(abspath $(CURDIR)/..)),toolchain)
	@$(MSG) $$(printf "%s MAKELEVEL: %02d, PARALLEL_MAKE: %s, %sARCH: %s, NAME: %s\n" "$$(date +%Y%m%d-%H%M%S)" $(MAKELEVEL) "$(PARALLEL_MAKE)" "$(STATUS_GCC)" "$(lastword $(subst -, ,$(TC_NAME)))-$(TC_VERS)" "toolchain") | tee --append $(STATUS_LOG)
else ifeq ($(notdir $(abspath $(CURDIR)/..)),toolkit)
	@$(MSG) $$(printf "%s MAKELEVEL: %02d, PARALLEL_MAKE: %s, %sARCH: %s, NAME: %s\n" "$$(date +%Y%m%d-%H%M%S)" $(MAKELEVEL) "$(PARALLEL_MAKE)" "$(STATUS_GCC)" "$(lastword $(subst -, ,$(TK_NAME)))-$(TK_VERS)" "toolkit") | tee --append $(STATUS_LOG)
else ifeq ($(notdir $(abspath $(CURDIR)/..)),kernel)
	@$(MSG) $$(printf "%s MAKELEVEL: %02d, PARALLEL_MAKE: %s, %sARCH: %s, NAME: %s\n" "$$(date +%Y%m%d-%H%M%S)" $(MAKELEVEL) "$(PARALLEL_MAKE)" "$(STATUS_GCC)" "$(lastword $(subst -, ,$(KERNEL_NAME)))-$(KERNEL_VERS)" "kernel") | tee --append $(STATUS_LOG)
else
	@$(MSG) $$(printf "%s MAKELEVEL: %02d, PARALLEL_MAKE: %s, %sARCH: %s, NAME: %s\n" "$$(date +%Y%m%d-%H%M%S)" $(MAKELEVEL) "$(PARALLEL_MAKE)" "$(STATUS_GCC)" "$(ARCH)-$(TCVERSION)" "$(NAME)") | tee --append $(STATUS_LOG)
endif

post_status_target: $(STATUS_TARGET)

ifeq ($(wildcard $(STATUS_COOKIE)),)
status: $(STATUS_COOKIE)

$(STATUS_COOKIE): $(POST_STATUS_TARGET)
	$(create_target_dir)
	@touch -f $@
else
status: ;
endif


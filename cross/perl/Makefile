PKG_NAME = perl
PKG_VERS = 5.30.0
PKG_EXT = tar.gz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = https://www.cpan.org/src/5.0/
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)
SHELL := /bin/bash

DEPENDS = cross/libiconv cross/zlib cross/expat cross/libxml2
##PERL_DL_NONLAZY = 0  ## Still fails on JSON/BackportPP.pm line 1491

HOMEPAGE = https://www.perl.org/
COMMENT  = Highly capable, feature-rich programming language with over 30 years of development.
LICENSE  = Copyright (C) 1993-2005, by Larry Wall and others, falls under GPLv1 or later or "Artistic License".

EXTRAS_MODULES = local::lib Bundle::CPAN JSON Bundle::LWP Bundle::XML
EXTRAS_MODULES += Dist::CheckConflicts Module::Build PerlIO::gzip Sub::Install Sub::Name Term::ProgressBar Unicode::String
EXTRAS_MODULES += Log::Dispatch Log::Log4perl
EXTRAS_MODULES += Test::LeakTrace Test::Perl::Critic Test::Pod Test::Pod::Coverage
EXTRAS_MODULES += File::Find::Rule File::Slurp

CONFIGURE_ARGS = -de -Dprefix=$(INSTALL_PREFIX)
CONFIGURE_ARGS += -Doptimize='-fPIC -O3 -march=native -pipe'
PRE_CONFIGURE_TARGET = perl_pre_configure
POST_CONFIGURE_TARGET = perl_post_configure
#PRE_INSTALL_TARGET = perl_pre_install
INSTALL_TARGET = perl_install

include ../../mk/spksrc.cross-cc.mk

###
### HOMEPAGE: https://arsv.github.io/perl-cross/index.html
###
### Perl cross-compiling helper script.
### Perl cross-compilable cpan modules helper script.
###
.PHONY: perl_pre_configure
perl_pre_configure: 
	@$(MSG) "Downloading perl-cross"
	@$(RUN) wget https://github.com/arsv/perl-cross/releases/download/1.3/perl-cross-1.3.tar.gz -P $(WORK_DIR)
	@$(MSG) "Applying perl-cross"
	@$(MSG) tar -zxvf $(WORK_DIR)/perl-cross-1.3.tar.gz -C $(WORK_DIR)/$(PKG_DIR) --strip=1
	@$(RUN) tar -zxvf $(WORK_DIR)/perl-cross-1.3.tar.gz -C $(WORK_DIR)/$(PKG_DIR) --strip=1
	@$(MSG) "Download all necessary modules"
	@$(RUN) curl -L https://cpanmin.us | perl - App::cpanminus
	@$(RUN) $(bash)
	PKG_DIR=$(WORK_DIR)/$(PKG_DIR) ./extensions.bash

###
### Disable usage of xlocale.h header file (i_xlocale='undef')
###
.PHONY: perl_post_configure
perl_post_configure: 
	@$(MSG) "Fix glibc xlocale.h header dependency"
	sed -i '/i_xlocale=/s/=.*/='"'"'undef'"'"';/' $(WORK_DIR)/$(PKG_DIR)/config.sh 2>/dev/null

.PHONY: perl_pre_install
perl_pre_install:
	# Run all tests
	$(RUN) make test

.PHONY: perl_install
perl_install:
	$(RUN) $(MAKE) install DESTDIR=$(INSTALL_DIR) PREFIX=$(INSTALL_PREFIX)

# Allow overriding the name, used by spk/zsh-static.
SPK_NAME ?= perl
SPK_VERS = 5.30.0
SPK_REV = 5
SPK_ICON = ../perl/src/perl.png
#DSM_UI_DIR = app

DEPENDS = cross/$(SPK_NAME)

MAINTAINER = th0ma7
DESCRIPTION = Perl is a highly capable, feature-rich programming language with over 30 years of development.
DESCRIPTION_FRE = Perl est un langage de programmation très performant et riche en fonctionnalités, développé depuis plus de 30 ans.
RELOAD_UI = no
DISPLAY_NAME = Perl
STARTABLE = no
CHANGELOG = "New package to replace old and incomplete synology provided"

HOMEPAGE = https://www.perl.org/
LICENSE = Copyright (C) 1993-2005, by Larry Wall and others, falls under GPLv1 or later or "Artistic License".

SERVICE_SETUP = ../perl/src/service-setup.sh

include ../../mk/spksrc.common.mk
include ../../mk/spksrc.spk.mk

# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit x-modular multilib-native

DESCRIPTION="X.Org xtrans library"
EGIT_REPO_URI="git://anongit.freedesktop.org/git/xorg/lib/lib${PN}"

KEYWORDS=""
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=x11-misc/util-macros-1.2"

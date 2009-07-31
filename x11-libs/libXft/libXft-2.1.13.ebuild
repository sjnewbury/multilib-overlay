# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXft/libXft-2.1.13.ebuild,v 1.8 2009/04/16 01:58:43 jer Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular flag-o-matic multilib-native

DESCRIPTION="X.Org Xft library"

KEYWORDS="~alpha amd64 ~arm hppa ia64 ~mips ppc ppc64 ~s390 sh sparc x86 ~x86-fbsd"

RDEPEND="x11-libs/libXrender[$(get_ml_usedeps)]
	x11-libs/libX11[$(get_ml_usedeps)]
	x11-libs/libXext[$(get_ml_usedeps)]
	x11-proto/xproto
	media-libs/freetype[$(get_ml_usedeps)]
	>=media-libs/fontconfig-2.2[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}"

ml-native_pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}

ml-native_src_install() {
	multilib-native_check_inherited_funcs src_install
	prep_ml_binaries /usr/bin/xft-config 
}

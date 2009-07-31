# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXft/libXft-2.1.12.ebuild,v 1.10 2007/07/02 13:36:24 armin76 Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular flag-o-matic multilib-native

DESCRIPTION="X.Org Xft library"

KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"

RDEPEND="x11-libs/libXrender
	x11-libs/libX11
	x11-libs/libXext
	x11-proto/xproto
	media-libs/freetype
	>=media-libs/fontconfig-2.2"
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

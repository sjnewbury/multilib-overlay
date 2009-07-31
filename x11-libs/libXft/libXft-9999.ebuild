# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXft/libXft-2.1.13.ebuild,v 1.1 2008/07/05 06:27:20 dberkholz Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2"

inherit x-modular flag-o-matic multilib-native

DESCRIPTION="X.Org Xft library"

KEYWORDS=""

RDEPEND="x11-libs/libXrender[lib32?]
	x11-libs/libX11[lib32?]
	x11-libs/libXext[lib32?]
	x11-proto/xproto
	media-libs/freetype[lib32?]
	>=media-libs/fontconfig-2.2[lib32?]"
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

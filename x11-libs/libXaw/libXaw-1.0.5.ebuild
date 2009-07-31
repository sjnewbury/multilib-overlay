# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXaw/libXaw-1.0.5.ebuild,v 1.8 2009/04/16 02:13:33 jer Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xaw library"

KEYWORDS="~alpha amd64 ~arm hppa ia64 ~mips ppc ppc64 ~s390 sh sparc x86 ~x86-fbsd"

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXt[lib32?]
	x11-libs/libXmu[lib32?]
	x11-libs/libXpm[lib32?]
	x11-proto/xproto"
DEPEND="${RDEPEND}"

ml-native_pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}

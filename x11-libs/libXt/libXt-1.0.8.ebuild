# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXt/libXt-1.0.8.ebuild,v 1.9 2010/10/28 11:43:34 scarabeus Exp $

EAPI=3
inherit xorg-2 flag-o-matic toolchain-funcs multilib-native

DESCRIPTION="X.Org Xt library"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libSM[lib32?]
	x11-proto/xproto
	x11-proto/kbproto"
DEPEND="${RDEPEND}"

multilib-native_pkg_setup_internal() {
	xorg-2_pkg_setup

	if tc-is-cross-compiler; then
		export CFLAGS_FOR_BUILD="${BUILD_CFLAGS}"
	fi
}

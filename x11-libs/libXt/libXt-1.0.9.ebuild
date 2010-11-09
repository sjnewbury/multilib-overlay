# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXt/libXt-1.0.9.ebuild,v 1.2 2010/11/01 14:28:03 scarabeus Exp $

EAPI=3
inherit xorg-2 toolchain-funcs multilib-native

DESCRIPTION="X.Org Xt library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libSM[lib32?]
	x11-libs/libICE[lib32?]
	x11-proto/xproto
	x11-proto/kbproto"
DEPEND="${RDEPEND}"

multilib-native_pkg_setup_internal() {
	xorg-2_pkg_setup

	tc-is-cross-compiler && export CFLAGS_FOR_BUILD="${BUILD_CFLAGS}"
}

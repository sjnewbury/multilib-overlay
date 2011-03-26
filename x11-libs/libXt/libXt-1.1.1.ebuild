# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXt/libXt-1.1.1.ebuild,v 1.4 2011/03/26 10:48:19 fauli Exp $

EAPI=4
inherit xorg-2 toolchain-funcs multilib-native

DESCRIPTION="X.Org Xt library"

KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ppc ppc64 ~s390 ~sh ~sparc x86 ~ppc-aix ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
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

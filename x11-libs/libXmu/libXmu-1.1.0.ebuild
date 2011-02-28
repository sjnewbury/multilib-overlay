# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXmu/libXmu-1.1.0.ebuild,v 1.9 2011/02/14 22:54:14 xarthisius Exp $

EAPI=3
inherit xorg-2 multilib-native

DESCRIPTION="X.Org Xmu library"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~x86-fbsd ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc ipv6"

RDEPEND="x11-libs/libXt[lib32?]
	x11-libs/libXext[lib32?]
	x11-libs/libX11[lib32?]
	x11-proto/xextproto"
DEPEND="${RDEPEND}
	doc? ( app-text/xmlto )"

multilib-native_pkg_setup_internal() {
	xorg-2_pkg_setup

	CONFIGURE_OPTIONS="$(use_enable ipv6)
		$(use_enable doc docs)
		$(use_with doc xmlto)
		--without-fop"
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXaw/libXaw-1.0.7.ebuild,v 1.11 2010/02/25 07:28:52 abcd Exp $

EAPI="2"

inherit x-modular flag-o-matic multilib-native

DESCRIPTION="X.Org Xaw library"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~x86-fbsd ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXt[lib32?]
	x11-libs/libXmu[lib32?]
	x11-libs/libXpm[lib32?]
	x11-proto/xproto"
DEPEND="${RDEPEND}
	doc? ( sys-apps/groff )
	"

multilib-native_pkg_setup_internal() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}

multilib-native_src_configure_internal() {
	CONFIGURE_OPTIONS="$(use_enable doc docs)"
	x-modular_src_configure
}

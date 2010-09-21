# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libX11/libX11-1.3.4.ebuild,v 1.7 2010/09/19 20:07:12 armin76 Exp $

EAPI=3
inherit xorg-2 toolchain-funcs flag-o-matic multilib-native

DESCRIPTION="X.Org X11 library"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ~ppc ~ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="doc ipv6 test +xcb"

RDEPEND=">=x11-libs/xtrans-1.2.3[lib32?]
	x11-proto/kbproto
	>=x11-proto/xproto-7.0.13
	xcb? ( >=x11-libs/libxcb-1.1.92[lib32?] )
	!xcb? (
		x11-libs/libXau[lib32?]
		x11-libs/libXdmcp[lib32?]
	)"
DEPEND="${RDEPEND}
	doc? (
		app-text/ghostscript-gpl[lib32?]
		sys-apps/groff
	)
	test? ( dev-lang/perl[lib32?] )
	x11-proto/xf86bigfontproto
	!xcb? (
		x11-proto/bigreqsproto
		x11-proto/xcmiscproto
	)
	x11-proto/inputproto
	x11-proto/xextproto"

multilib-native_pkg_setup_internal() {
	xorg-2_pkg_setup
	CONFIGURE_OPTIONS="$(use_enable doc specs) $(use_enable ipv6)
		$(use_with xcb)"
	# xorg really doesn't like xlocale disabled.
	# $(use_enable nls xlocale)
}

multilib-native_src_compile_internal() {
	# [Cross-Compile Love] Disable {C,LD}FLAGS and redefine CC= for 'makekeys'
	( filter-flags -m* ; cd src/util && make CC=$(tc-getBUILD_CC) CFLAGS="${CFLAGS}" LDFLAGS="" clean all)
	xorg-2_src_compile
}

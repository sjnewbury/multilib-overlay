# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
inherit xorg-2 toolchain-funcs flag-o-matic multilib-native

DESCRIPTION="X.Org X11 library"

KEYWORDS=""
IUSE="doc ipv6 test +xcb"

RDEPEND=">=x11-libs/xtrans-1.2.3
	x11-proto/kbproto
	>=x11-proto/xproto-7.0.13
	xcb? ( >=x11-libs/libxcb-1.1.92[lib32?] )
	!xcb? (
		x11-libs/libXau[lib32?]
		x11-libs/libXdmcp[lib32?]
	)"
DEPEND="${RDEPEND}
	doc? (
		app-text/ghostscript-gpl
		sys-apps/groff
	)
	test? ( dev-lang/perl[lib32?] )
	xcb? (
		x11-proto/bigreqsproto
		x11-proto/xcmiscproto
		x11-proto/xf86bigfontproto
	)
	x11-proto/inputproto
	x11-proto/xextproto"

multilib-native_pkg_setup_internal() {
	CONFIGURE_OPTIONS="$(use_enable ipv6)
		$(use_with xcb) $(use_with test perl)"
	# xorg really doesn't like xlocale disabled.
	# $(use_enable nls xlocale)
}

multilib-native_src_compile_internal() {
	# [Cross-Compile Love] Disable {C,LD}FLAGS and redefine CC= for 'makekeys'
	( filter-flags -m* ; cd src/util && make CC=$(tc-getBUILD_CC) CFLAGS="${CFLAGS}" LDFLAGS="" clean all)
	xorg-2_src_compile
}

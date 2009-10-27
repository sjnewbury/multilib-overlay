# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libX11/libX11-1.3.2.ebuild,v 1.1 2009/10/25 20:42:00 scarabeus Exp $

EAPI="2"

inherit x-modular toolchain-funcs flag-o-matic multilib-native

DESCRIPTION="X.Org X11 library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="ipv6 test +xcb"

RDEPEND=">=x11-libs/xtrans-1.2.3[lib32?]
	x11-proto/kbproto
	>=x11-proto/xproto-7.0.13
	xcb? ( >=x11-libs/libxcb-1.1.92[lib32?] )
	!xcb? (
		x11-libs/libXau[lib32?]
		x11-libs/libXdmcp[lib32?]
	)"
DEPEND="${RDEPEND}
	test? ( dev-lang/perl )
	x11-proto/xf86bigfontproto
	xcb? (
		x11-proto/bigreqsproto
		x11-proto/xcmiscproto
	)
	x11-proto/inputproto
	x11-proto/xextproto"

multilib-native_pkg_setup_internal() {
	CONFIGURE_OPTIONS="$(use_enable ipv6)
		$(use_with xcb) $(use_with test perl)"
	# xorg really doesn't like xlocale disabled.
	# $(use_enable nls xlocale)
}

multilib-native_pkg_compile_internal() {
	x-modular_src_configure
	# [Cross-Compile Love] Disable {C,LD}FLAGS and redefine CC= for 'makekeys'
	( filter-flags -m* ; cd src/util && make CC=$(tc-getBUILD_CC) CFLAGS="${CFLAGS}" LDFLAGS="" clean all)
	x-modular_src_make
}

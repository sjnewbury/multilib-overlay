# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libX11/libX11-1.4.0.ebuild,v 1.3 2010/12/23 11:55:10 ssuominen Exp $

EAPI=3
inherit xorg-2 toolchain-funcs flag-o-matic multilib-native

DESCRIPTION="X.Org X11 library"

KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc ipv6 test"

RDEPEND=">=x11-libs/libxcb-1.1.92[lib32?]
	x11-libs/xtrans[lib32?]
	x11-proto/xf86bigfontproto
	x11-proto/inputproto
	x11-proto/kbproto
	x11-proto/xextproto
	>=x11-proto/xproto-7.0.13"
DEPEND="${RDEPEND}
	doc? ( app-text/xmlto )
	test? ( dev-lang/perl[lib32?] )"

multilib-native_pkg_setup_internal() {
	xorg-2_pkg_setup
	CONFIGURE_OPTIONS="
		$(use_with doc xmlto)
		$(use_enable doc specs)
		$(use_enable ipv6)
		--without-fop
	"
}

multilib-native_src_compile_internal() {
	# [Cross-Compile Love] Disable {C,LD}FLAGS and redefine CC= for 'makekeys'
	( filter-flags -m* ; cd src/util && make CC=$(tc-getBUILD_CC) CFLAGS="${CFLAGS}" LDFLAGS="" clean all)
	xorg-2_src_compile
}

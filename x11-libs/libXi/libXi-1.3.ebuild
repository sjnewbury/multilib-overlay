# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXi/libXi-1.3.ebuild,v 1.1 2009/10/03 15:25:11 scarabeus Exp $

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xi library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="
	>=x11-libs/libX11-1.3[lib32?]
	>=x11-libs/libXext-1.1[lib32?]
	>=x11-proto/inputproto-2.0
"
DEPEND="${RDEPEND}
	>=x11-proto/xproto-7.0.16
"

pkg_postinst() {
	x-modular_pkg_postinst

	ewarn "Some special keys and keyboard layouts may stop working."
	ewarn "To fix them, recompile xorg-server."
}

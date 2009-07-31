# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXi/libXi-1.2.1.ebuild,v 1.1 2009/02/26 07:49:17 dberkholz Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xi library"

KEYWORDS=""

RDEPEND="x11-libs/libX11[$(get_ml_usedeps)?]
	x11-libs/libXext[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
	x11-proto/xproto
	=x11-proto/inputproto-9999"

pkg_postinst() {
	x-modular_pkg_postinst

	ewarn "Some special keys and keyboard layouts may stop working."
	ewarn "To fix them, recompile xorg-server."
}

# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXi/libXi-1.1.3.ebuild,v 1.8 2008/01/13 09:23:20 vapier Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xi library"

KEYWORDS="alpha amd64 arm ~hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"

RDEPEND="x11-libs/libX11[$(get_ml_usedeps)?]
	x11-libs/libXext[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
	x11-proto/xproto
	>=x11-proto/inputproto-1.4"

pkg_postinst() {
	x-modular_pkg_postinst

	ewarn "Some special keys and keyboard layouts may stop working."
	ewarn "To fix them, recompile xorg-server."
}

# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXfixes/libXfixes-4.0.3.ebuild,v 1.11 2007/06/24 22:37:03 vapier Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xfixes library"

KEYWORDS=""

RDEPEND="x11-libs/libX11[$(get_ml_usedeps)?]
	>=x11-proto/fixesproto-4
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/xextproto"

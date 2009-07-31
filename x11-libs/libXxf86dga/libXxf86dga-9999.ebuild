# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXxf86dga/libXxf86dga-1.0.2.ebuild,v 1.6 2008/02/05 11:48:06 corsair Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xxf86dga library"

KEYWORDS=""

RDEPEND="x11-libs/libX11[$(get_ml_usedeps)]
	x11-libs/libXext[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
	x11-proto/xproto
	>=x11-proto/xf86dgaproto-2.0.3"

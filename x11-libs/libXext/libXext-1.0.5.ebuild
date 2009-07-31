# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXext/libXext-1.0.4.ebuild,v 1.1 2008/02/29 19:52:41 dberkholz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xext library"

KEYWORDS=""

RDEPEND=">=x11-libs/libX11-1.2[lib32?]
	>=x11-proto/xextproto-7.0.5"
DEPEND="${RDEPEND}
	>=x11-proto/xproto-7.0.15"

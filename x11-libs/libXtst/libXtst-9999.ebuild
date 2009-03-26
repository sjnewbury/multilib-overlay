# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xtst library"

KEYWORDS=""
IUSE=""

RDEPEND="x11-libs/libX11
	x11-proto/recordproto
	x11-libs/libXext"
DEPEND="${RDEPEND}
	~app-text/docbook-xml-dtd-4.1.2
	app-text/xmlto
	x11-proto/inputproto"

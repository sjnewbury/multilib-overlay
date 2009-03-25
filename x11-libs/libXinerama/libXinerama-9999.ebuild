# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXinerama/libXinerama-1.0.3.ebuild,v 1.1 2008/03/10 01:51:14 dberkholz Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xinerama library"

KEYWORDS=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXext[lib32?]"
DEPEND="${RDEPEND}
	x11-proto/xineramaproto"

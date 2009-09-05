# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit x-modular multilib-native

DESCRIPTION="X.Org XTrap library"

KEYWORDS=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXt[lib32?]
	x11-libs/libXext[lib32?]"
DEPEND="${RDEPEND}
	x11-proto/trapproto"

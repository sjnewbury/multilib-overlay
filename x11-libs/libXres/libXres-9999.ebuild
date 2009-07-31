# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit x-modular multilib-native

EGIT_REPO_URI="git://anongit.freedesktop.org/git/xorg/lib/libXRes"
DESCRIPTION="X.Org XRes library"

KEYWORDS=""

RDEPEND="x11-libs/libX11[$(get_ml_usedeps)?]
	x11-libs/libXext[$(get_ml_usedeps)?]
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/resourceproto"

# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit x-modular flag-o-matic

DESCRIPTION="X.Org Xfont library"

KEYWORDS=""
IUSE="ipv6"

RDEPEND="x11-libs/xtrans[$(get_ml_usedeps)?]
	x11-libs/libfontenc[$(get_ml_usedeps)?]
	x11-proto/xproto
	x11-proto/fontsproto
	>=media-libs/freetype-2[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
	x11-proto/fontcacheproto"

CONFIGURE_OPTIONS="$(use_enable ipv6)
	--with-encodingsdir=/usr/share/fonts/encodings"

ml-native_pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}

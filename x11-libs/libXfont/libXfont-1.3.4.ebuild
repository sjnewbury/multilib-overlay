# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXfont/libXfont-1.3.4.ebuild,v 1.1 2009/01/13 02:40:07 dberkholz Exp $

EAPI=2

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular flag-o-matic multilib-native

DESCRIPTION="X.Org Xfont library"

KEYWORDS="~alpha amd64 ~arm hppa ia64 ~m68k ~mips ppc ppc64 ~s390 sh sparc x86 ~x86-fbsd"
IUSE="ipv6"

RDEPEND="x11-libs/xtrans[$(get_ml_usedeps)]
	x11-libs/libfontenc[$(get_ml_usedeps)]
	x11-proto/xproto
	x11-proto/fontsproto
	>=media-libs/freetype-2[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
	x11-proto/fontcacheproto"

CONFIGURE_OPTIONS="$(use_enable ipv6)
	--with-bzip2
	--with-encodingsdir=/usr/share/fonts/encodings"

ml-native_pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}

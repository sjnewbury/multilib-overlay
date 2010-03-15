# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
inherit xorg-2 multilib-native

DESCRIPTION="X.Org SM library"

KEYWORDS=""
IUSE="ipv6"

RDEPEND="x11-libs/libICE[lib32?]
	x11-libs/xtrans
	x11-proto/xproto"
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="$(use_enable ipv6)"

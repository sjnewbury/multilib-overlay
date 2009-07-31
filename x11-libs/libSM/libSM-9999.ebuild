# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libSM/libSM-1.1.0.ebuild,v 1.3 2008/08/23 14:21:50 aballier Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org SM library"

KEYWORDS=""
IUSE="ipv6"

RDEPEND="x11-libs/libICE[$(get_ml_usedeps)]
	x11-libs/xtrans
	x11-proto/xproto
	|| ( sys-libs/e2fsprogs-libs[lib32] sys-fs/e2fsprogs[lib32] )"
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="$(use_enable ipv6)"

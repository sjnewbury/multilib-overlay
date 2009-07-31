# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXpm/libXpm-3.5.7.ebuild,v 1.9 2009/02/03 19:23:30 beandog Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xpm library"

KEYWORDS=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXt[lib32?]
	x11-libs/libXext[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/gettext
	x11-proto/xproto"

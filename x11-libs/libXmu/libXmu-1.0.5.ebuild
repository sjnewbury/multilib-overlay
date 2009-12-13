# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXmu/libXmu-1.0.5.ebuild,v 1.3 2009/12/10 19:20:07 fauli Exp $

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xmu library"

KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd"
IUSE="ipv6"

RDEPEND="x11-libs/libXt[lib32?]
	x11-libs/libXext[lib32?]
	x11-libs/libX11[lib32?]
	x11-proto/xextproto"
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="$(use_enable ipv6)"

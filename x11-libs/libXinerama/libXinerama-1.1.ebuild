# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXinerama/libXinerama-1.1.ebuild,v 1.2 2009/11/01 20:26:30 zmedico Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xinerama library"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

COMMON_DEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXext[lib32?]"
RDEPEND="${COMMON_DEPEND}
	!<x11-proto/xineramaproto-1.2"
DEPEND="${COMMON_DEPEND}
	x11-proto/xextproto
	>=x11-proto/xineramaproto-1.2"

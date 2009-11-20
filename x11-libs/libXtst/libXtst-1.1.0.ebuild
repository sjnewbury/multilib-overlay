# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXtst/libXtst-1.1.0.ebuild,v 1.2 2009/10/26 09:45:58 remi Exp $

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xtst library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="x11-libs/libX11[lib32?]
	>=x11-libs/libXext-1.0.99.4[lib32?]
	x11-libs/libXi[lib32?]
	>=x11-proto/recordproto-1.13.99.1
	>=x11-proto/xextproto-7.0.99.3"
DEPEND="${RDEPEND}
	x11-proto/inputproto"

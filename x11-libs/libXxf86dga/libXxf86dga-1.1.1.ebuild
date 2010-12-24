# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXxf86dga/libXxf86dga-1.1.1.ebuild,v 1.8 2010/08/02 18:28:01 armin76 Exp $

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xxf86dga library"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXext[lib32?]
	x11-proto/xproto
	>=x11-proto/xf86dgaproto-2.0.99.2"
DEPEND="${RDEPEND}"
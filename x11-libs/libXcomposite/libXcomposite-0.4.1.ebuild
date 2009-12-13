# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXcomposite/libXcomposite-0.4.1.ebuild,v 1.4 2009/12/10 19:14:10 fauli Exp $

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xcomposite library"

KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd"
IUSE="doc"

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXfixes[lib32?]
	x11-libs/libXext[lib32?]
	>=x11-proto/compositeproto-0.4
	x11-proto/xproto"
DEPEND="${RDEPEND}
	doc? ( app-text/xmlto )"

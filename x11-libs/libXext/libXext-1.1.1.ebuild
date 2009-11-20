# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXext/libXext-1.1.1.ebuild,v 1.1 2009/10/25 20:32:42 scarabeus Exp $

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xext library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=x11-libs/libX11-1.1.99.1[lib32?]"
DEPEND="${RDEPEND}
	>=x11-proto/xextproto-7.0.99.2
	>=x11-proto/xproto-7.0.13"

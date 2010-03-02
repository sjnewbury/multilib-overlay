# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/xtrans/xtrans-1.2.3.ebuild,v 1.11 2009/06/23 19:18:27 klausman Exp $

EAPI="2"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular multilib-native

DESCRIPTION="X.Org xtrans library"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

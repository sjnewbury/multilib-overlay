# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXpm/libXpm-3.5.7.ebuild,v 1.8 2008/02/05 11:44:48 corsair Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

XMODULAR_MULTILIB="yes"
inherit x-modular multilib-xlibs

DESCRIPTION="X.Org Xpm library"

KEYWORDS="alpha amd64 arm ~hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXt[lib32?]
	x11-libs/libXext[lib32?]"
DEPEND="${RDEPEND}
	x11-proto/xproto"

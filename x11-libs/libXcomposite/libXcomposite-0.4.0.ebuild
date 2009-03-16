# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXcomposite/libXcomposite-0.4.0.ebuild,v 1.9 2008/12/07 12:24:26 vapier Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

XMODULAR_MULTILIB="yes"
inherit x-modular multilib-xlibs

DESCRIPTION="X.Org Xcomposite library"

KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 ~s390 sh sparc x86 ~x86-fbsd"

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXfixes[lib32?]
	x11-libs/libXext[lib32?]
	>=x11-proto/compositeproto-0.4
	x11-proto/xproto"
DEPEND="${RDEPEND}"

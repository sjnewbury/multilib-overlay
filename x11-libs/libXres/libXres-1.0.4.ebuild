# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXres/libXres-1.0.4.ebuild,v 1.10 2010/01/19 20:09:18 armin76 Exp $

EAPI="2"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular multilib-native

DESCRIPTION="X.Org XRes library"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXext[lib32?]
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/resourceproto"

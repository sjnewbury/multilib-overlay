# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libICE/libICE-1.0.4.ebuild,v 1.8 2008/01/13 09:23:21 vapier Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-xlibs

DESCRIPTION="X.Org ICE library"

KEYWORDS="alpha amd64 arm ~hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="ipv6"

RDEPEND="x11-libs/xtrans
	x11-proto/xproto"
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="$(use_enable ipv6)"

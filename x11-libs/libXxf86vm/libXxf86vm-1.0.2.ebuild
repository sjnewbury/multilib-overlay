# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXxf86vm/libXxf86vm-1.0.2.ebuild,v 1.1 2008/07/05 06:28:48 dberkholz Exp $

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

XMODULAR_MULTILIB="yes"
XMODULAR_SUPRESS_TESTS="yes"
inherit x-modular multilib-xlibs

DESCRIPTION="X.Org Xxf86vm library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"

RDEPEND="x11-libs/libX11
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/xproto
	x11-proto/xf86vidmodeproto"

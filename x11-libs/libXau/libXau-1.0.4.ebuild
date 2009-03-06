# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXau/libXau-1.0.4.ebuild,v 1.1 2008/09/06 06:57:17 dberkholz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

XMODULAR_MULTILIB="yes"
inherit x-modular multilib-xlibs

DESCRIPTION="X.Org Xau library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"

RDEPEND="x11-proto/xproto"
DEPEND="${RDEPEND}
	>=x11-misc/util-macros-1.1"

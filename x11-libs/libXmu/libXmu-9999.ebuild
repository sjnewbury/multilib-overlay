# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

inherit x-modular multilib-xlibs

DESCRIPTION="X.Org Xmu library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="ipv6"

RDEPEND="x11-libs/libXt
	x11-libs/libXext
	x11-libs/libX11
	x11-proto/xproto"
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="$(use_enable ipv6)"

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXpm/libXpm-3.5.7.ebuild,v 1.10 2009/04/16 02:20:17 jer Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xpm library"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"

RDEPEND="x11-libs/libX11[$(get_ml_usedeps)?]
	x11-libs/libXt[$(get_ml_usedeps)?]
	x11-libs/libXext[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
	sys-devel/gettext
	x11-proto/xproto"

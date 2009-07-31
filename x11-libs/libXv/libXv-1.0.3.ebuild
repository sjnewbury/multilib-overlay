# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXv/libXv-1.0.3.ebuild,v 1.11 2007/08/07 13:16:26 gustavoz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xv library"

KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"

RDEPEND="x11-libs/libX11[$(get_ml_usedeps)?]
	x11-libs/libXext[$(get_ml_usedeps)?]
	x11-proto/videoproto
	x11-proto/xproto"
DEPEND="${RDEPEND}"

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXTrap/libXTrap-1.0.0.ebuild,v 1.15 2009/05/05 07:01:55 ssuominen Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular multilib-native

DESCRIPTION="X.Org XTrap library"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="x11-libs/libX11[$(get_ml_usedeps)]
	x11-libs/libXt[$(get_ml_usedeps)]
	x11-libs/libXext[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
	x11-proto/trapproto"

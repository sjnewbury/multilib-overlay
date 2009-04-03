# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/xtrans/xtrans-1.0.4.ebuild,v 1.6 2007/12/16 17:55:37 corsair Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular multilib-native

DESCRIPTION="X.Org xtrans library"

KEYWORDS="alpha amd64 ~arm ~hppa ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh sparc ~x86 ~x86-fbsd"

RDEPEND=""
DEPEND="${RDEPEND}"

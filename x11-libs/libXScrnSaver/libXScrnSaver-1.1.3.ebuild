# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXScrnSaver/libXScrnSaver-1.1.3.ebuild,v 1.1 2008/03/18 04:15:29 dberkholz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

XMODULAR_MULTILIB="yes"
XMODULAR_SUPRESS_TESTS="yes"
inherit x-modular multilib-xlibs

DESCRIPTION="X.Org XScrnSaver library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"

RDEPEND="x11-libs/libX11
	x11-libs/libXext"
DEPEND="${RDEPEND}
	>=x11-proto/scrnsaverproto-1.1"

# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit x-modular multilib-xlibs

DESCRIPTION="X.Org Xau library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"

RDEPEND="x11-proto/xproto"
DEPEND="${RDEPEND}
	>=x11-misc/util-macros-1.1"

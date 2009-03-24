# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXrender/libXrender-0.9.4.ebuild,v 1.6 2007/12/20 07:24:27 opfer Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-xlibs

DESCRIPTION="X.Org Xrender library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"

RDEPEND="x11-libs/libX11[lib32?]
		=x11-proto/renderproto-9999
		x11-proto/xproto"
DEPEND="${RDEPEND}"

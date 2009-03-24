# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXdmcp/libXdmcp-1.0.2.ebuild,v 1.11 2007/08/07 13:08:33 gustavoz Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2" 

inherit x-modular multilib-xlibs

DESCRIPTION="X.Org Xdmcp library"

KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"

RDEPEND="x11-proto/xproto"
DEPEND="${RDEPEND}
	>=x11-misc/util-macros-1.1"

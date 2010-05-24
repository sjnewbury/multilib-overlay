# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/jre/jre-1.4.2.ebuild,v 1.4 2006/11/27 00:17:10 vapier Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Virtual for FAM"
HOMEPAGE=""
SRC_URI=""
SLOT=0

LICENSE="as-is"
KEYWORDS="amd64 ia64 ppc ppc64 x86"
IUSE=""

RDEPEND="|| (
		app-admin/gamin[lib32?]
	)"
DEPEND=""

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/ghostscript/ghostscript-0.ebuild,v 1.7 2009/05/26 05:59:39 pva Exp $

EAPI="2"

DESCRIPTION="Virtual for Ghostscript"
HOMEPAGE="http://www.ghostscript.com"
SRC_URI=""
LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="lib32"
DEPEND=""
RDEPEND="|| (
		app-text/ghostscript-gpl[lib32?]
		app-text/ghostscript-gnul[lib32?]
	)"

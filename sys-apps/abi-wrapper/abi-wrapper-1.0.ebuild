# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Wraps binarys that behave abi dependand"
HOMEPAGE="www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND=""

src_install()
{
	exeinto /usr/bin
	doexe ${FILESDIR}/abi-wrapper
}

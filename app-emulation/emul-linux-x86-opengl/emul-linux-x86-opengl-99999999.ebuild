# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* amd64 amd64-linux"
SLOT="0"
IUSE="-nodep"

RDEPEND="
!nodep? (
	media-libs/freeglut[lib32]
	media-libs/mesa[lib32]
	x11-libs/libdrm[lib32]
)
"


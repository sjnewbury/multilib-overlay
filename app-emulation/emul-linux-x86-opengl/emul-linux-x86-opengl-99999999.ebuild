# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* ~amd64 ~amd64-linux"
SLOT="0"
IUSE="-nodep"

RDEPEND="
!nodep? (
	media-libs/freeglut[multilib_abi_x86]
	media-libs/mesa[multilib_abi_x86]
	x11-libs/libdrm[multilib_abi_x86]
)
"


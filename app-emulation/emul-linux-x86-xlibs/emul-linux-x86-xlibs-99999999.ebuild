# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* ~amd64"
SLOT="0"
IUSE="opengl -nodep"

DEPEND="!nodep? ( opengl? ( app-admin/eselect-opengl ) )"

RDEPEND="!nodep? ( =app-emulation/emul-linux-x86-baselibs-${PV}
		media-libs/fontconfig[multilib_abi_x86]
		media-libs/freetype[multilib_abi_x86]
		opengl? ( media-libs/mesa[multilib_abi_x86]
			media-libs/freeglut[multilib_abi_x86] )
		x11-libs/libdrm[multilib_abi_x86]
		x11-libs/libICE[multilib_abi_x86]
		x11-libs/libSM[multilib_abi_x86]
		x11-libs/libX11[multilib_abi_x86]
		x11-libs/libXau[multilib_abi_x86]
		x11-libs/libXaw[multilib_abi_x86]
		x11-libs/libXcomposite[multilib_abi_x86]
		x11-libs/libXcursor[multilib_abi_x86]
		x11-libs/libXdamage[multilib_abi_x86]
		x11-libs/libXdmcp[multilib_abi_x86]
		x11-libs/libXext[multilib_abi_x86]
		x11-libs/libXfixes[multilib_abi_x86]
		x11-libs/libXft[multilib_abi_x86]
		x11-libs/libXi[multilib_abi_x86]
		x11-libs/libXinerama[multilib_abi_x86]
		x11-libs/libXmu[multilib_abi_x86]
		x11-libs/libXp[multilib_abi_x86]
		x11-libs/libXpm[multilib_abi_x86]
		x11-libs/libXrandr[multilib_abi_x86]
		x11-libs/libXrender[multilib_abi_x86]
		x11-libs/libXScrnSaver[multilib_abi_x86]
		x11-libs/libXt[multilib_abi_x86]
		x11-libs/libXtst[multilib_abi_x86]
		x11-libs/libXv[multilib_abi_x86]
		x11-libs/libXvMC[multilib_abi_x86]
		x11-libs/libXxf86dga[multilib_abi_x86]
		x11-libs/libXxf86vm[multilib_abi_x86]
		x11-libs/pixman[multilib_abi_x86] )"

pkg_postinst() {
	#update GL symlinks
	use opengl && eselect opengl set --use-old
}

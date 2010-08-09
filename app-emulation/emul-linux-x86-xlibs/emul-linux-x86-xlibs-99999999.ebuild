# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* amd64 amd64-linux"
SLOT="0"
IUSE="opengl -nodep"

DEPEND="
!nodep? ( 
	opengl? ( app-admin/eselect-opengl ) 
)"

RDEPEND="
!nodep? (
	>=app-emulation/emul-linux-x86-baselibs-20071114
	media-libs/fontconfig[lib32]
	media-libs/freetype[lib32]
	opengl? ( media-libs/mesa[lib32]
		media-libs/freeglut[lib32]
		x11-libs/libdrm[lib32] )
	x11-libs/libICE[lib32]
	x11-libs/libSM[lib32]
	x11-libs/libX11[lib32]
	x11-libs/libXau[lib32]
	x11-libs/libXaw[lib32]
	x11-libs/libXcomposite[lib32]
	x11-libs/libXcursor[lib32]
	x11-libs/libXdamage[lib32]
	x11-libs/libXdmcp[lib32]
	x11-libs/libXext[lib32]
	x11-libs/libXfixes[lib32]
	x11-libs/libXft[lib32]
	x11-libs/libXi[lib32]
	x11-libs/libXinerama[lib32]
	x11-libs/libXmu[lib32]
	x11-libs/libXp[lib32]
	x11-libs/libXpm[lib32]
	x11-libs/libXrandr[lib32]
	x11-libs/libXrender[lib32]
	x11-libs/libXScrnSaver[lib32]
	x11-libs/libXt[lib32]
	x11-libs/libXtst[lib32]
	x11-libs/libXv[lib32]
	x11-libs/libXvMC[lib32]
	x11-libs/libXxf86dga[lib32]
	x11-libs/libXxf86vm[lib32]
	x11-libs/pixman[lib32]
)"

pkg_postinst() {
        #update GL symlinks
        use opengl && eselect opengl set --use-old
}

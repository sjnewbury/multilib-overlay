# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* amd64"
SLOT="0"
IUSE="opengl -nodep"

DEPEND="
!nodep? ( 
	opengl? ( app-admin/eselect-opengl ) 
)"

RDEPEND="
!nodep? (
	>=app-emulation/emul-linux-x86-baselibs-20071114
	media-libs/fontconfig[$(get_ml_usedeps)]
	media-libs/freetype[$(get_ml_usedeps)]
	opengl? ( media-libs/mesa[$(get_ml_usedeps)]
		media-libs/freeglut[$(get_ml_usedeps)] )
	x11-libs/libdrm[$(get_ml_usedeps)]
	x11-libs/libICE[$(get_ml_usedeps)]
	x11-libs/libSM[$(get_ml_usedeps)]
	x11-libs/libX11[$(get_ml_usedeps)]
	x11-libs/libXau[$(get_ml_usedeps)]
	x11-libs/libXaw[$(get_ml_usedeps)]
	x11-libs/libXcomposite[$(get_ml_usedeps)]
	x11-libs/libXcursor[$(get_ml_usedeps)]
	x11-libs/libXdamage[$(get_ml_usedeps)]
	x11-libs/libXdmcp[$(get_ml_usedeps)]
	x11-libs/libXext[$(get_ml_usedeps)]
	x11-libs/libXfixes[$(get_ml_usedeps)]
	x11-libs/libXft[$(get_ml_usedeps)]
	x11-libs/libXi[$(get_ml_usedeps)]
	x11-libs/libXinerama[$(get_ml_usedeps)]
	x11-libs/libXmu[$(get_ml_usedeps)]
	x11-libs/libXp[$(get_ml_usedeps)]
	x11-libs/libXpm[$(get_ml_usedeps)]
	x11-libs/libXrandr[$(get_ml_usedeps)]
	x11-libs/libXrender[$(get_ml_usedeps)]
	x11-libs/libXScrnSaver[$(get_ml_usedeps)]
	x11-libs/libXt[$(get_ml_usedeps)]
	x11-libs/libXtst[$(get_ml_usedeps)]
	x11-libs/libXv[$(get_ml_usedeps)]
	x11-libs/libXvMC[$(get_ml_usedeps)]
	x11-libs/libXxf86dga[$(get_ml_usedeps)]
	x11-libs/libXxf86vm[$(get_ml_usedeps)]
	x11-libs/pixman[$(get_ml_usedeps)]
)"

pkg_postinst() {
        #update GL symlinks
        use opengl && eselect opengl set --use-old
}

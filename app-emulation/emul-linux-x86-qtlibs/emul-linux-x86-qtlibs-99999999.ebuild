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
	>=app-emulation/emul-linux-x86-baselibs-20081109
		>=app-emulation/emul-linux-x86-soundlibs-20081109
		>=app-emulation/emul-linux-x86-xlibs-20081109
	=x11-libs/qt-3*[lib32?]
)"

pkg_postinst() {
        #update GL symlinks
        use opengl && eselect opengl set --use-old
}

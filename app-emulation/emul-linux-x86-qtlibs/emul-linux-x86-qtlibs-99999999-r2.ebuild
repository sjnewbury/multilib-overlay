# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* amd64 amd64-linux"
SLOT="0"
IUSE="opengl -nodep qt3 +qt4 +dbus +qt3support +svg +webkit +sql"

DEPEND="
!nodep? (
	opengl? ( app-admin/eselect-opengl )
)"

RDEPEND="
!nodep? (
	>=app-emulation/emul-linux-x86-baselibs-20081109
		>=app-emulation/emul-linux-x86-soundlibs-20081109
		>=app-emulation/emul-linux-x86-xlibs-20081109
	qt3? ( =x11-libs/qt-3*[lib32] )
	qt4? ( 	x11-libs/qt-core:4[lib32]
		x11-libs/qt-gui:4[lib32]
		svg? ( x11-libs/qt-svg:4[lib32] )
		sql? ( x11-libs/qt-sql:4[lib32] )
		x11-libs/qt-script:4[lib32]
		x11-libs/qt-xmlpatterns:4[lib32]
		dbus? ( x11-libs/qt-dbus:4[lib32] )
		opengl? ( x11-libs/qt-opengl:4[lib32] )
		|| ( x11-libs/qt-phonon:4[lib32?] media-sound/phonon[lib32] )
		qt3support? ( x11-libs/qt-qt3support:4[lib32] )
		webkit? ( x11-libs/qt-webkit:4[lib32] )
		x11-libs/qt-test:4[lib32]
		x11-libs/qt-assistant:4[lib32] ) )"

pkg_postinst() {
	#update GL symlinks
	use opengl && eselect opengl set --use-old
}

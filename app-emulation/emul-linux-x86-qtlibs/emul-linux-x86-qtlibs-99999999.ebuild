# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* ~amd64"
SLOT="0"
IUSE="+dbus kde -nodep opengl +qt3 +qt4 +svg +sql +webkit"

DEPEND="!nodep? ( opengl? ( app-admin/eselect-opengl ) )"

RDEPEND="!nodep? ( =app-emulation/emul-linux-x86-baselibs-${PV}
		=app-emulation/emul-linux-x86-soundlibs-${PV}
		=app-emulation/emul-linux-x86-xlibs-${PV}
		qt3? ( !qt4? ( x11-libs/qt:3[multilib_abi_x86] ) )
		qt4? ( x11-libs/qt-core:4[multilib_abi_x86]
			x11-libs/qt-gui:4[multilib_abi_x86]
			svg? ( x11-libs/qt-svg:4[multilib_abi_x86] )
			sql? ( x11-libs/qt-sql:4[multilib_abi_x86] )
			x11-libs/qt-script:4[multilib_abi_x86]
			x11-libs/qt-xmlpatterns:4[multilib_abi_x86]
			dbus? ( x11-libs/qt-dbus:4[multilib_abi_x86] )
			opengl? ( x11-libs/qt-opengl:4[multilib_abi_x86] )
			!kde? ( || ( x11-libs/qt-phonon:4[multilib_abi_x86] media-sound/phonon[multilib_abi_x86] ) )
			kde? ( media-sound/phonon[multilib_abi_x86] )
			qt3? ( x11-libs/qt-qt3support:4[multilib_abi_x86] )
			webkit? ( x11-libs/qt-webkit:4[multilib_abi_x86] )
			x11-libs/qt-test:4[multilib_abi_x86]
			x11-libs/qt-assistant:4[multilib_abi_x86] ) )"

pkg_postinst() {
	#update GL symlinks
	use opengl && eselect opengl set --use-old
}

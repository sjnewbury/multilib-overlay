# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-multimedia/qt-multimedia-4.7.0.ebuild,v 1.4 2010/11/06 09:35:44 wired Exp $

EAPI="3"
inherit qt4-build multilib-native

DESCRIPTION="The Qt multimedia module"
SLOT="4"
KEYWORDS="~amd64 ~arm ~ia64 ~ppc ~ppc64 -sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="iconv"

DEPEND="!aqua? ( media-libs/alsa-lib[lib32?] )
	~x11-libs/qt-core-${PV}[aqua=,debug=,lib32?]
	~x11-libs/qt-gui-${PV}[aqua=,debug=,lib32?]"
RDEPEND="${DEPEND}"

multilib-native_pkg_setup_internal() {
	QT4_TARGET_DIRECTORIES="src/multimedia"
	QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
		include/Qt/
		include/QtCore/
		include/QtGui/
		include/QtMultimedia/
		include/QtNetwork/
		src/src.pro
		src/3rdparty/
		src/corelib/
		src/gui/
		src/network/
		src/plugins/
		src/tools/"

	qt4-build_pkg_setup
}

multilib-native_src_configure_internal() {
	myconf="${myconf} $(qt_use iconv) -no-xkb  -no-fontconfig -no-xrender
		-no-xrandr -no-xfixes -no-xcursor -no-xinerama -no-xshape -no-sm
		-no-opengl -no-nas-sound -no-dbus -no-cups -no-nis -no-gif -no-libpng
		-no-libmng -no-libjpeg -no-openssl -system-zlib -no-webkit -no-phonon
		-no-xmlpatterns -no-freetype -no-libtiff  -no-accessibility
		-no-fontconfig -no-sql-mysql -no-sql-psql -no-sql-ibase -no-sql-sqlite
		-no-sql-sqlite2 -no-sql-odbc -no-glib -no-opengl -no-svg -no-gtkstyle
		-no-phonon-backend -no-script -no-scripttools -no-cups -no-xsync
		-no-xinput"

	qt4-build_src_configure
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-test/qt-test-4.7.0.ebuild,v 1.1 2010/09/21 15:05:31 tampakrap Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The testing framework module for the Qt toolkit"
SLOT="4"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="iconv"

DEPEND="~x11-libs/qt-core-${PV}[debug=,lib32?]"
RDEPEND="${DEPEND}"

multilib-native_pkg_setup_internal() {
	QT4_TARGET_DIRECTORIES="src/testlib"
	QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
		include/QtTest/
		include/QtCore/
		src/corelib/"

	qt4-build_pkg_setup
}

multilib-native_src_configure_internal() {
	myconf="${myconf} $(qt_use iconv) -no-xkb  -no-fontconfig -no-xrender
		-no-xrandr -no-xfixes -no-xcursor -no-xinerama -no-xshape -no-sm
		-no-opengl -no-nas-sound -no-dbus -no-cups -no-nis -no-gif -no-libpng
		-no-libmng -no-libjpeg -no-openssl -system-zlib -no-webkit -no-phonon
		-no-qt3support -no-xmlpatterns -no-freetype -no-libtiff
		-no-accessibility -no-fontconfig -no-glib -no-opengl -no-svg"
	qt4-build_src_configure
}

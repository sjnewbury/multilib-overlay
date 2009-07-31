# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-svg/qt-svg-4.4.2.ebuild,v 1.9 2009/02/18 19:56:49 jer Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The SVG module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="alpha amd64 hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE=""

DEPEND="~x11-libs/qt-gui-${PV}[lib32?]
	!<=x11-libs/qt-4.4.0_alpha:${SLOT}"
RDEPEND="${DEPEND}"

QCONFIG_ADD="svg"
QCONFIG_DEFINE="QT_SVG"
QT4_TARGET_DIRECTORIES="
src/svg
src/plugins/imageformats/svg
src/plugins/iconengines/svgiconengine"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}"

ml-native_src_configure() {
	local myconf
	myconf="${myconf} -svg -no-xkb -no-tablet -no-fontconfig -no-xrender -no-xrandr
		-no-xfixes -no-xcursor -no-xinerama -no-xshape -no-sm -no-opengl
		-no-nas-sound -no-dbus -iconv -no-cups -no-nis -no-gif -no-libpng
		-no-libmng -no-libjpeg -no-openssl -system-zlib -no-webkit -no-phonon
		-no-qt3support -no-xmlpatterns -no-freetype -no-libtiff -no-accessibility
		-no-fontconfig -no-glib -no-opengl"

	qt4-build_src_configure
}

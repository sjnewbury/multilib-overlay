# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-demo/qt-demo-4.7.2.ebuild,v 1.1 2011/03/01 19:07:32 tampakrap Exp $

EAPI="3"
inherit qt4-build multilib-native

DESCRIPTION="Demonstration module of the Qt toolkit"
SLOT="4"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="kde qt3support"

DEPEND="~x11-libs/qt-assistant-${PV}:${SLOT}[aqua=,lib32?]
	~x11-libs/qt-core-${PV}:${SLOT}[aqua=,qt3support=,lib32?]
	~x11-libs/qt-dbus-${PV}:${SLOT}[aqua=,lib32?]
	~x11-libs/qt-gui-${PV}:${SLOT}[aqua=,qt3support=,lib32?]
	~x11-libs/qt-multimedia-${PV}:${SLOT}[aqua=,lib32?]
	~x11-libs/qt-opengl-${PV}:${SLOT}[aqua=,qt3support=,lib32?]
	!kde? ( || ( ~x11-libs/qt-phonon-${PV}:${SLOT}[aqua=,lib32?]
		media-sound/phonon[aqua=,lib32?] ) )
	kde? ( media-sound/phonon[aqua=,lib32?] )
	~x11-libs/qt-script-${PV}:${SLOT}[aqua=,lib32?]
	~x11-libs/qt-sql-${PV}:${SLOT}[aqua=,qt3support=,lib32?]
	~x11-libs/qt-svg-${PV}:${SLOT}[aqua=,lib32?]
	~x11-libs/qt-test-${PV}:${SLOT}[aqua=,lib32?]
	~x11-libs/qt-webkit-${PV}:${SLOT}[aqua=,lib32?]
	~x11-libs/qt-xmlpatterns-${PV}:${SLOT}[aqua=,lib32?]"

RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${PN}-4.6-plugandpaint.patch" )

multilib-native_pkg_setup_internal() {
	QT4_TARGET_DIRECTORIES="demos
		examples"
	QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
		doc/src/images
		src/
		include/
		tools/"

	qt4-build_pkg_setup
}

multilib-native_src_configure_internal() {
	myconf="${myconf} $(qt_use qt3support)"
	qt4-build_src_configure
}

multilib-native_src_install_internal() {
	insinto "${QTDOCDIR#${EPREFIX}}"/src
	doins -r "${S}"/doc/src/images || die "Installing images failed."

	qt4-build_src_install
}

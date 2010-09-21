# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-demo/qt-demo-4.7.0.ebuild,v 1.1 2010/09/21 14:45:36 tampakrap Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="Demonstration module of the Qt toolkit"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="~x11-libs/qt-assistant-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-core-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-dbus-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-gui-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-multimedia-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-opengl-${PV}:${SLOT}[lib32?]
	|| ( ~x11-libs/qt-phonon-${PV}:${SLOT}[lib32?] media-sound/phonon[lib32?] )
	~x11-libs/qt-script-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-sql-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-svg-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-test-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-webkit-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-xmlpatterns-${PV}:${SLOT}[lib32?]"
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

multilib-native_src_install_internal() {
	insinto ${QTDOCDIR}/src
	doins -r "${S}"/doc/src/images || die

	qt4-build_src_install
}

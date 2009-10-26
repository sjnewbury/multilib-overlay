# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-demo/qt-demo-4.5.2.ebuild,v 1.4 2009/10/09 06:07:37 maekke Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="Demonstration module of the Qt toolkit"
SLOT="4"
KEYWORDS="amd64 arm ~hppa ppc ~ppc64 x86 ~x86-fbsd"
IUSE="kde"

DEPEND="~x11-libs/qt-assistant-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-core-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-dbus-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-gui-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-opengl-${PV}:${SLOT}[lib32?]
	|| ( ~x11-libs/qt-phonon-${PV}:${SLOT}[lib32?] media-sound/phonon[lib32?] )
	kde? ( media-sound/phonon[lib32?] )
	~x11-libs/qt-qt3support-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-script-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-sql-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-svg-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-test-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-webkit-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-xmlpatterns-${PV}:${SLOT}[lib32?]"

RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="demos
	examples"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
	doc/src/images
	src/
	include/
	tools/"

multilib-native_src_prepare_internal() {
	# patch errors in arthurwidgets and plugandpaint
	epatch "${FILESDIR}"/qt-demo-4.5.0-fixes.patch

	qt4-build_src_prepare
}

multilib-native_src_install_internal() {
	insinto ${QTDOCDIR}/src
	doins -r "${S}"/doc/src/images || die "Installing images failed."

	qt4-build_src_install
}

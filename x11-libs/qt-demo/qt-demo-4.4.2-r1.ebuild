# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-demo/qt-demo-4.4.2-r1.ebuild,v 1.1 2009/02/01 22:43:43 yngwin Exp $

EAPI="1"
inherit qt4-build multilib-native

DESCRIPTION="Demonstration module of the Qt toolkit"
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="~amd64 ~hppa ~ppc ~ppc64 ~x86"
IUSE=""

DEPEND="~x11-libs/qt-assistant-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-core-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-dbus-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-gui-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-opengl-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-qt3support-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-script-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-sql-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-svg-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-test-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-webkit-${PV}:${SLOT}[lib32?]
	~x11-libs/qt-xmlpatterns-${PV}:${SLOT}[lib32?]
	|| ( ~x11-libs/qt-phonon-${PV}:${SLOT}[lib32?] media-sound/phonon[lib32?] )"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="demos
	examples"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
	doc/src/images"

multilib-native_src_compile_internal() {
	# Doesn't find qt-gui and fails linking
	sed -e '/QT_BUILD_TREE/ s:=:+=:' \
		-i "${S}"/examples/tools/plugandpaint/plugandpaint.pro \
		|| die "Fixing plugandpaint example failed."

	qt4-build_src_compile
}

multilib-native_src_install_internal() {
	insinto ${QTDOCDIR}/src
	doins -r "${S}"/doc/src/images || die "Installing images failed."

	qt4-build_src_install
}

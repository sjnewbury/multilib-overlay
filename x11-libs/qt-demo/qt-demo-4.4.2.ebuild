# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-demo/qt-demo-4.4.2.ebuild,v 1.5 2009/02/18 20:18:03 jer Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="Demonstration module of the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="amd64 hppa ~ppc ppc64 x86"
IUSE=""

DEPEND="
	~x11-libs/qt-assistant-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-core-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-dbus-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-gui-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-opengl-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-phonon-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-qt3support-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-script-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-sql-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-svg-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-test-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-webkit-${PV}:${SLOT}[$(get_ml_usedeps)?]
	~x11-libs/qt-xmlpatterns-${PV}:${SLOT}[$(get_ml_usedeps)?]
	!<=x11-libs/qt-4.4.0_alpha:${SLOT}
	"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="demos
	examples"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
	doc/src/images"

ml-native_src_configure() {
	# Doesn't find qt-gui and fails linking
	sed -e '/QT_BUILD_TREE/ s:=:+=:' \
		-i "${S}"/examples/tools/plugandpaint/plugandpaint.pro \
		|| die "Fixing plugandpaint example failed."

	qt4-build_src_configure
}

ml-native_src_install() {
	insinto ${QTDOCDIR}/src
	doins -r "${S}"/doc/src/images || die "Installing images failed."

	qt4-build_src_install
}

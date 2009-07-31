# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-qt3support/qt-qt3support-4.5.1.ebuild,v 1.14 2009/06/08 22:32:28 jer Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The Qt3 support module for the Qt toolkit"
SLOT="4"
KEYWORDS="alpha amd64 arm hppa ~ia64 ~mips ppc ~ppc64 ~sparc x86 ~x86-fbsd"
IUSE="+accessibility kde phonon"

DEPEND="~x11-libs/qt-core-${PV}[debug=,qt3support,$(get_ml_usedeps)?]
	~x11-libs/qt-gui-${PV}[accessibility=,debug=,qt3support,$(get_ml_usedeps)?]
	~x11-libs/qt-sql-${PV}[debug=,qt3support,$(get_ml_usedeps)?]
	phonon? ( || ( ~x11-libs/qt-phonon-${PV}[debug=,$(get_ml_usedeps)?]
		media-sound/phonon[gstreamer,$(get_ml_usedeps)?] )
		kde? ( media-sound/phonon[$(get_ml_usedeps)?] ) )"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="
src/qt3support
src/tools/uic3
tools/designer/src/plugins/widgets
tools/qtconfig
tools/porting"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
src/
include/
tools/"

ml-native_src_configure() {
	myconf="${myconf} -qt3support
		$(qt_use phonon gstreamer)
		$(qt_use phonon)
		$(qt_use accessibility)"
	qt4-build_src_configure
}

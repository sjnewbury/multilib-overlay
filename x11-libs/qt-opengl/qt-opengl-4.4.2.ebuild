# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-opengl/qt-opengl-4.4.2.ebuild,v 1.9 2009/02/18 19:58:24 jer Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The OpenGL module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="alpha amd64 hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="+qt3support"

DEPEND="~x11-libs/qt-gui-${PV}[$(get_ml_usedeps)]
	!<=x11-libs/qt-4.4.0_alpha:${SLOT}
	virtual/opengl[$(get_ml_usedeps)]
	virtual/glu[$(get_ml_usedeps)]"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/opengl"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}"
QCONFIG_ADD="opengl"
QCONFIG_DEFINE="QT_OPENGL"

ml-native_pkg_setup() {
	use qt3support && QT4_BUILT_WITH_USE_CHECK="${QT4_BUILT_WITH_USE_CHECK}
		~x11-libs/qt-core-${PV} qt3support"
	qt4-build_pkg_setup
}

ml-native_src_configure() {
	local myconf
	myconf="${myconf} -opengl
		$(qt_use qt3support)"

	# Not building tools/designer/src/plugins/tools/view3d as it's commented out of the build in the source
	qt4-build_src_configure
}

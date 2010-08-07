# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-phonon/qt-phonon-4.6.2.ebuild,v 1.6 2010/08/04 15:06:03 maekke Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The Phonon module for the Qt toolkit"
SLOT="4"
KEYWORDS="~alpha amd64 arm ~hppa ~ia64 ppc ppc64 ~sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="dbus"

DEPEND="~x11-libs/qt-gui-${PV}[aqua=,debug=,glib,qt3support,lib32?]
	!kde-base/phonon-kde
	!kde-base/phonon-xine
	!media-sound/phonon
	!aqua? ( media-libs/gstreamer[lib32?]
			 media-plugins/gst-plugins-meta )
	aqua? ( ~x11-libs/qt-opengl-${PV}[aqua,lib32?] )
	dbus? ( ~x11-libs/qt-dbus-${PV}[aqua=,debug=,lib32?] )"
RDEPEND="${DEPEND}"

multilib-native_pkg_setup_internal() {
	QT4_TARGET_DIRECTORIES="
		src/phonon
		src/plugins/phonon
		tools/designer/src/plugins/phononwidgets"
	QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
		include/
		src
		tools"

	QCONFIG_ADD="phonon"
	use aqua || QCONFIG_DEFINE="QT_GSTREAMER"

	qt4-build_pkg_setup
}

multilib-native_src_configure_internal() {
	myconf="${myconf} -phonon -phonon-backend -no-opengl -no-svg
		$(qt_use dbus qdbus)"

	qt4-build_src_configure
}

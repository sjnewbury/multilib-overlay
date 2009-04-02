# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-phonon/qt-phonon-4.4.2.ebuild,v 1.6 2009/02/18 19:57:30 jer Exp $

EAPI="1"
inherit qt4-build multilib-native

DESCRIPTION="The Phonon module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="amd64 hppa ppc ppc64 x86"
IUSE="dbus"

DEPEND="~x11-libs/qt-gui-${PV}[lib32?]
	!<=x11-libs/qt-4.4.0_alpha:${SLOT}
	!media-sound/phonon
	media-libs/gstreamer[lib32?]
	media-libs/gst-plugins-base[lib32?]
	dbus? ( =x11-libs/qt-dbus-${PV}[lib32?] )"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="
src/phonon
src/plugins/phonon"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
src/3rdparty/kdelibs/phonon/
src/3rdparty/kdebase/runtime/phonon/"
QCONFIG_ADD="phonon"
QCONFIG_DEFINE="QT_GSTREAMER"

# see bug 225721
QT4_BUILT_WITH_USE_CHECK="~x11-libs/qt-core-${PV} glib
~x11-libs/qt-gui-${PV} glib"

multilib-native_src_compile_internal() {
	local myconf
	myconf="${myconf} -phonon -no-opengl -no-svg
		$(qt_use dbus qdbus)"

	qt4-build_src_compile
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/phonon/phonon-4.3.50_pre20090520.ebuild,v 1.1 2009/12/04 16:15:21 scarabeus Exp $

EAPI="2"

inherit cmake-utils multilib-native

MY_P="${PN}-4.4_pre20090520"

DESCRIPTION="KDE multimedia API"
HOMEPAGE="http://phonon.kde.org"
SRC_URI="http://dev.gentooexperimental.org/~alexxy/kde/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ppc ppc64 ~sparc x86 ~x86-fbsd"
IUSE="debug gstreamer +xcb +xine"

RDEPEND="
	!kde-base/phonon-xine
	!x11-libs/qt-phonon:4
	>=x11-libs/qt-test-4.4.0:4[lib32?]
	>=x11-libs/qt-dbus-4.4.0:4[lib32?]
	>=x11-libs/qt-gui-4.4.0:4[lib32?]
	>=x11-libs/qt-opengl-4.4.0:4[lib32?]
	gstreamer? (
		media-libs/gstreamer[lib32?]
		media-libs/gst-plugins-base[lib32?]
	)
	xine? (
		>=media-libs/xine-lib-1.1.15-r1[lib32?,xcb?]
		xcb? ( x11-libs/libxcb[lib32?] )
	)
"
DEPEND="${RDEPEND}
	>=kde-base/automoc-0.9.87
"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use !xine && use !gstreamer; then
		die "you must at least select one backend for phonon"
	fi
}

multilib-native_src_configure_internal() {
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use_with gstreamer GStreamer)
		$(cmake-utils_use_with gstreamer GStreamerPlugins)
		$(cmake-utils_use_with xine)"

	if use xine; then
		mycmakeargs="${mycmakeargs}
			$(cmake-utils_use_with xcb)"
	else
		sed -i -e '/xine/d' CMakeLists.txt || die "sed failed"
	fi

	cmake-utils_src_configure
}

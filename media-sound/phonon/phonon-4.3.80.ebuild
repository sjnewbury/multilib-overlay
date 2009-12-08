# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/phonon/phonon-4.3.80.ebuild,v 1.2 2009/12/04 16:04:17 scarabeus Exp $

EAPI="2"

inherit cmake-utils multilib-native

DESCRIPTION="KDE multimedia API"
HOMEPAGE="http://phonon.kde.org"
SRC_URI="mirror://kde/unstable/phonon/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="alsa debug gstreamer pulseaudio +xcb +xine"

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
		alsa? ( media-libs/alsa-lib[lib32?] )
	)
	pulseaudio? (
		dev-libs/glib:2[lib32?]
		>=media-sound/pulseaudio-0.9.21[lib32?,glib] )
	xine? (
		>=media-libs/xine-lib-1.1.15-r1[lib32?,xcb?]
		xcb? ( x11-libs/libxcb[lib32?] )
	)
"
DEPEND="${RDEPEND}
	>=kde-base/automoc-0.9.87
"

pkg_setup() {
	if use !xine && use !gstreamer; then
		die "you must at least select one backend for phonon"
	fi
}

multilib-native_src_configure_internal() {
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use_with alsa)
		$(cmake-utils_use_with gstreamer GStreamer)
		$(cmake-utils_use_with gstreamer GStreamerPlugins)
		$(cmake-utils_use_with pulseaudio PulseAudio)
		$(cmake-utils_use_with pulseaudio GLib2)
		$(cmake-utils_use_with xine)
		$(cmake-utils_use_with xcb)
	"

	cmake-utils_src_configure
}

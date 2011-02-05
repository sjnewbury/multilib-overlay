# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/phonon/phonon-9999.ebuild,v 1.1 2011/01/23 05:21:17 reavertm Exp $

EAPI="3"

inherit cmake-utils git multilib-native

DESCRIPTION="KDE multimedia API"
HOMEPAGE="https://projects.kde.org/projects/kdesupport/phonon"
EGIT_REPO_URI="git://anongit.kde.org/${PN}"

LICENSE="LGPL-2.1"
KEYWORDS=""
SLOT="0"
IUSE="debug gstreamer pulseaudio +vlc xine"

COMMON_DEPEND="
	>=x11-libs/qt-core-4.6.0:4[lib32?]
	>=x11-libs/qt-dbus-4.6.0:4[lib32?]
	>=x11-libs/qt-gui-4.6.0:4[lib32?]
	pulseaudio? (
		dev-libs/glib:2[lib32?]
		>=media-sound/pulseaudio-0.9.21[glib,lib32?]
	)
"
# directshow? ( media-sound/phonon-directshow )
# mmf? ( media-sound/phonon-mmf )
# mplayer? ( media-sound/phonon-mplayer )
# quicktime? ( media-sound/phonon-quicktime )
# waveout? ( media-sound/phonon-waveout )
PDEPEND="
	gstreamer? ( media-sound/phonon-gstreamer )
	vlc? ( >=media-sound/phonon-vlc-0.3.2 )
	xine? ( >=media-sound/phonon-xine-0.4.4 )
"
RDEPEND="${COMMON_DEPEND}
	!kde-base/phonon-xine
	!x11-libs/qt-phonon:4
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/automoc-0.9.87[lib32?]
	dev-util/pkgconfig[lib32?]
"

multilib-native_pkg_setup_internal() {
	if use !gstreamer && use !vlc && use !xine; then
		ewarn "You must at least select one backend for phonon to be usuable"
	fi
}

multilib-native_src_configure_internal() {
	local mycmakeargs=(
		$(cmake-utils_use_with pulseaudio GLIB2)
		$(cmake-utils_use_with pulseaudio PulseAudio)
	)
	cmake-utils_src_configure
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/tracker/tracker-9999.ebuild,v 1.7 2009/12/21 22:28:02 eva Exp $

EAPI="2"
G2CONF_DEBUG="no"

inherit autotools git gnome2 linux-info multilib-native

DESCRIPTION="A tagging metadata database, search tool and indexer"
HOMEPAGE="http://www.tracker-project.org/"
EGIT_REPO_URI="git://git.gnome.org/${PN}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
# USE="doc" is managed by eclass.
IUSE="applet deskbar doc eds exif gsf gstreamer gtk hal iptc +jpeg kmail laptop mp3 nautilus pdf playlist test +tiff +vorbis wv2 xine +xml xmp"

# Automagic, gconf, uuid, enca and probably more
# TODO: quill and streamanalyzer support
RDEPEND="
	>=app-i18n/enca-1.9[lib32?]
	>=dev-db/sqlite-3.6.16[threadsafe,lib32?]
	>=dev-libs/dbus-glib-0.78[lib32?]
	>=dev-libs/glib-2.16.0[lib32?]
	>=gnome-base/gconf-2[lib32?]
	>=media-gfx/imagemagick-5.2.1[png,jpeg=,lib32?]
	>=media-libs/libpng-1.2[lib32?]
	>=x11-libs/pango-1[lib32?]
	sys-apps/util-linux[lib32?]

	applet? (
		>=x11-libs/libnotify-0.4.3[lib32?]
		gnome-base/gnome-panel[lib32?]
		>=x11-libs/gtk+-2.16[lib32?] )
	deskbar? ( >=gnome-extra/deskbar-applet-2.19 )
	eds? (
		>=mail-client/evolution-2.25.5[lib32?]
		>=gnome-extra/evolution-data-server-2.25.5[lib32?] )
	exif? ( >=media-libs/libexif-0.6[lib32?] )
	iptc? ( media-libs/libiptcdata[lib32?] )
	jpeg? ( media-libs/jpeg[lib32?] )
	gsf? ( >=gnome-extra/libgsf-1.13[lib32?] )
	gstreamer? ( >=media-libs/gstreamer-0.10.12[lib32?] )
	!gstreamer? ( !xine? ( || ( media-video/totem media-video/mplayer ) ) )
	gtk? ( >=x11-libs/gtk+-2.16.0[lib32?] )
	laptop? (
		hal? ( >=sys-apps/hal-0.5[lib32?] )
		!hal? ( >=sys-apps/devicekit-power-007[lib32?] ) )
	mp3? ( >=media-libs/id3lib-3.8.3[lib32?] )
	nautilus? ( gnome-base/nautilus[lib32?] )
	pdf? (
		>=x11-libs/cairo-1[lib32?]
		>=virtual/poppler-glib-0.5[cairo,lib32?]
		>=virtual/poppler-utils-0.5
		>=x11-libs/gtk+-2.12[lib32?] )
	playlist? ( dev-libs/totem-pl-parser[lib32?] )
	tiff? ( media-libs/tiff[lib32?] )
	vorbis? ( >=media-libs/libvorbis-0.22[lib32?] )
	wv2? ( >=app-text/wv2-0.3.1[lib32?] )
	xine? ( >=media-libs/xine-lib-1[lib32?] )
	xml? ( >=dev-libs/libxml2-2.6[lib32?] )
	xmp? ( >=media-libs/exempi-2.1[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=sys-devel/gettext-0.14[lib32?]
	>=dev-util/pkgconfig-0.20[lib32?]
	applet? (
		dev-lang/vala
		>=dev-libs/libgee-0.3[lib32?] )
	gtk? (
		dev-lang/vala[lib32?]
		>=dev-libs/libgee-0.3[lib32?] )
	doc? (
		>=dev-util/gtk-doc-1.8
		media-gfx/graphviz[lib32?] )"
#	test? ( gcov )

DOCS="AUTHORS ChangeLog NEWS README"

function inotify_enabled() {
	if linux_config_exists; then
		if ! linux_chkconfig_present INOTIFY_USER; then
			echo
			ewarn "You should enable the INOTIFY support in your kernel."
			ewarn "Check the 'Inotify support for userland' under the 'File systems'"
			ewarn "option. It is marked as CONFIG_INOTIFY_USER in the config"
			echo
			die 'missing CONFIG_INOTIFY'
		fi
	else
		einfo "Could not check for INOTIFY support in your kernel."
	fi
}

multilib-native_pkg_setup_internal() {
	linux-info_pkg_setup

	inotify_enabled

	if use gstreamer ; then
		G2CONF="${G2CONF}
			--enable-video-extractor=gstreamer
			--enable-gstreamer-tagreadbin"
		# --enable-gstreamer-helix (real media)
	elif use xine ; then
		G2CONF="${G2CONF} --enable-video-extractor=xine"
	else
		G2CONF="${G2CONF} --enable-video-extractor=external"
	fi

	# hal and dk-p are used for AC power detection
	if use laptop; then
		G2CONF="${G2CONF} $(use_enable hal) $(use_enable !hal devkit-power)"
	else
		G2CONF="${G2CONF} --disable-hal --disable-devkit-power"
	fi

	G2CONF="${G2CONF}
		--disable-unac
		--disable-functional-tests
		$(use_enable applet tracker-status-icon)
		$(use_enable applet tracker-search-bar)
		$(use_enable deskbar deskbar-applet)
		$(use_enable eds evolution-miner)
		$(use_enable exif libexif)
		$(use_enable gsf libgsf)
		$(use_enable gtk libtrackergtk)
		$(use_enable gtk tracker-explorer)
		$(use_enable gtk tracker-preferences)
		$(use_enable gtk tracker-search-tool)
		$(use_enable iptc libiptcdata)
		$(use_enable jpeg libjpeg)
		$(use_enable kmail kmail-miner)
		$(use_enable mp3 id3lib)
		$(use_enable nautilus nautilus-extensions)
		$(use_enable pdf poppler-glib)
		$(use_enable playlist)
		$(use_enable test unit-tests)
		$(use_enable tiff libtiff)
		$(use_enable vorbis libvorbis)
		$(use_enable wv2 libwv2)
		$(use_enable xml libxml2)
		$(use_enable xmp exempi)"
		# FIXME: Missing files to run functional tests
		# $(use_enable test functional-tests)
		# FIXME: useless without quill (extract mp3 albumart...)
		# $(use_enable gtk gdkpixbuf)
}

multilib-native_src_unpack_internal() {
	git_src_unpack
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	gtkdocize || die "gtkdocize failed"
	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

src_test() {
	export XDG_CONFIG_HOME="${T}"
	emake check || die "tests failed"
}

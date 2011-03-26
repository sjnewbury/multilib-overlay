# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/tracker/tracker-0.10.4.ebuild,v 1.1 2011/03/18 07:50:16 eva Exp $

EAPI="3"
GCONF_DEBUG="no"
PYTHON_DEPEND="2:2.6"

inherit eutils gnome2 linux-info python virtualx multilib-native

DESCRIPTION="A tagging metadata database, search tool and indexer"
HOMEPAGE="http://www.tracker-project.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~x86"
# USE="doc" is managed by eclass.
IUSE="applet doc eds exif flac gif gnome-keyring gsf gstreamer gtk hal iptc +jpeg laptop mp3 nautilus networkmanager pdf playlist rss strigi test +tiff upnp +vorbis xine +xml xmp"

# Test suite highly disfunctional, loops forever
# putting aside for now
RESTRICT="test"

# TODO: rest -> flickr, qt vs. gdk
# vala is built with debug by default (see VALAFLAGS)
RDEPEND="
	>=app-i18n/enca-1.9[lib32?]
	>=dev-db/sqlite-3.7[threadsafe,lib32?]
	>=dev-libs/glib-2.26:2[lib32?]
	>=dev-libs/icu-4[lib32?]
	|| (
		>=media-gfx/imagemagick-5.2.1[png,jpeg=,lib32?]
		media-gfx/graphicsmagick[imagemagick,png,jpeg=] )
	>=media-libs/libpng-1.2[lib32?]
	>=x11-libs/pango-1[lib32?]
	sys-apps/util-linux[lib32?]

	applet? (
		>=gnome-base/gnome-panel-2.91[lib32?]
		>=x11-libs/gtk+-3:3[lib32?] )
	eds? (
		>=mail-client/evolution-2.91.90[lib32?]
		>=gnome-extra/evolution-data-server-2.91.90[lib32?] )
	exif? ( >=media-libs/libexif-0.6[lib32?] )
	flac? ( >=media-libs/flac-1.2.1[lib32?] )
	gif? ( media-libs/giflib[lib32?] )
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.26[lib32?] )
	gsf? (
		app-text/odt2txt
		>=gnome-extra/libgsf-1.13[lib32?] )
	upnp? ( >=media-libs/gupnp-dlna-0.5 )
	!upnp? (
		gstreamer? ( >=media-libs/gstreamer-0.10.12[lib32?] )
		!gstreamer? ( !xine? ( || ( media-video/totem media-video/mplayer ) ) )
	)
	gtk? (
		>=dev-libs/libgee-0.3[lib32?]
		>=x11-libs/gtk+-2.18:2[lib32?] )
	iptc? ( media-libs/libiptcdata[lib32?] )
	jpeg? ( virtual/jpeg:0[lib32?] )
	laptop? (
		hal? ( >=sys-apps/hal-0.5[lib32?] )
		!hal? ( >=sys-power/upower-0.9 ) )
	mp3? ( >=media-libs/taglib-1.6 )
	nautilus? (
		gnome-base/nautilus[lib32?]
		>=x11-libs/gtk+-2.18:2[lib32?] )
	networkmanager? ( >=net-misc/networkmanager-0.8[lib32?] )
	pdf? (
		>=x11-libs/cairo-1[lib32?]
		>=app-text/poppler-0.16[cairo,utils,lib32?]
		>=x11-libs/gtk+-2.12:2[lib32?] )
	playlist? ( dev-libs/totem-pl-parser )
	rss? ( net-libs/libgrss[lib32?] )
	strigi? ( >=app-misc/strigi-0.7[lib32?] )
	tiff? ( media-libs/tiff[lib32?] )
	vorbis? ( >=media-libs/libvorbis-0.22[lib32?] )
	xine? ( >=media-libs/xine-lib-1[lib32?] )
	xml? ( >=dev-libs/libxml2-2.6[lib32?] )
	xmp? ( >=media-libs/exempi-2.1[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17[lib32?]
	>=dev-util/pkgconfig-0.20[lib32?]
	applet? ( >=dev-lang/vala-0.11.4:0.12[lib32?] )
	gtk? (
		app-office/dia
		>=dev-lang/vala-0.11.4:0.12[lib32?]
		>=dev-libs/libgee-0.3[lib32?] )
	doc? (
		>=dev-util/gtk-doc-1.8
		media-gfx/graphviz[lib32?] )
	test? (
		>=dev-libs/dbus-glib-0.82-r1[lib32?]
		>=sys-apps/dbus-1.3.1[X,lib32?] )
"

function inotify_enabled() {
	if linux_config_exists; then
		if ! linux_chkconfig_present INOTIFY_USER; then
			ewarn "You should enable the INOTIFY support in your kernel."
			ewarn "Check the 'Inotify support for userland' under the 'File systems'"
			ewarn "option. It is marked as CONFIG_INOTIFY_USER in the config"
			die 'missing CONFIG_INOTIFY'
		fi
	else
		einfo "Could not check for INOTIFY support in your kernel."
	fi
}

multilib-native_pkg_setup_internal() {
	linux-info_pkg_setup

	inotify_enabled

	if use upnp ; then
		G2CONF="${G2CONF} --enable-video-extractor=gupnp-dlna"
	elif use gstreamer ; then
		G2CONF="${G2CONF}
			--enable-video-extractor=gstreamer
			--enable-gstreamer-tagreadbin"
		# --enable-gstreamer-helix (real media)
	elif use xine ; then
		G2CONF="${G2CONF} --enable-video-extractor=xine"
	else
		G2CONF="${G2CONF} --enable-video-extractor=external"
	fi

	# hal and upower are used for AC power detection
	if use laptop; then
		G2CONF="${G2CONF} $(use_enable hal) $(use_enable !hal upower)"
	else
		G2CONF="${G2CONF} --disable-hal --disable-upower"
	fi

	if use applet || use gtk; then
		G2CONF="${G2CONF} VALAC=$(type -P valac-0.12)"
	fi

	# unicode-support: libunistring, libicu or glib ?
	G2CONF="${G2CONF}
		--enable-tracker-fts
		--with-enca
		--with-unicode-support=libicu
		--enable-guarantee-metadata
		$(use_enable applet tracker-search-bar)
		$(use_enable eds miner-evolution)
		$(use_enable exif libexif)
		$(use_enable flac libflac)
		$(use_enable gnome-keyring)
		$(use_enable gsf libgsf)
		$(use_enable gtk tracker-explorer)
		$(use_enable gtk tracker-preferences)
		$(use_enable gtk tracker-needle)
		$(use_enable iptc libiptcdata)
		$(use_enable jpeg libjpeg)
		$(use_enable mp3 taglib)
		$(use_enable nautilus nautilus-extension)
		$(use_enable networkmanager network-manager)
		$(use_enable pdf poppler)
		$(use_enable playlist)
		$(use_enable rss miner-rss)
		$(use_enable strigi libstreamanalyzer)
		$(use_enable test functional-tests)
		$(use_enable test unit-tests)
		$(use_enable tiff libtiff)
		$(use_enable vorbis libvorbis)
		$(use_enable xml libxml2)
		$(use_enable xmp exempi)"
		# FIXME: handle gdk vs qt for mp3 thumbnail extract
		# $(use_enable gtk gdkpixbuf)

	DOCS="AUTHORS ChangeLog NEWS README"

	python_set_active_version 2
}

multilib-native_src_prepare_internal() {
	# Fix build failures with USE=strigi
	epatch "${FILESDIR}/${PN}-0.8.0-strigi.patch"

	# Fix functional tests scripts
	find "${S}" -name "*.pyc" -delete
	python_convert_shebangs 2 "${S}"/tests/tracker-writeback/*.py
	python_convert_shebangs 2 "${S}"/tests/functional-tests/*.py
	python_convert_shebangs 2 "${S}"/utils/data-generators/cc/{*.py,generate}
	python_convert_shebangs 2 "${S}"/utils/gtk-sparql/*.py
	python_convert_shebangs 2 "${S}"/examples/rss-reader/*.py

	# FIXME: report broken tests
	sed -e '/\/libtracker-miner\/tracker-password-provider\/setting/,+1 s:^\(.*\)$:/*\1*/:' \
		-e '/\/libtracker-miner\/tracker-password-provider\/getting/,+1 s:^\(.*\)$:/*\1*/:' \
		-i tests/libtracker-miner/tracker-password-provider-test.c || die
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check XDG_DATA_HOME="${T}" XDG_CONFIG_HOME="${T}" || die "tests failed"
}

multilib-native_src_install_internal() {
	gnome2_src_install
	# Tracker and none of the plugins it provides needs la files
	find "${ED}" -name "*.la" -delete || die
}

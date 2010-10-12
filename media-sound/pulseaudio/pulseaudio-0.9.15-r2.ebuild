# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/pulseaudio/pulseaudio-0.9.15-r2.ebuild,v 1.16 2010/09/21 22:36:43 abcd Exp $

EAPI=2

inherit eutils libtool flag-o-matic autotools multilib-native

DESCRIPTION="A networked sound server with an advanced plugin system"
HOMEPAGE="http://www.pulseaudio.org/"
if [[ ${PV/_rc/} == ${PV} ]]; then
	SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.gz"
else
	SRC_URI="http://0pointer.de/public/${P/_rc/-test}.tar.gz"
fi

S="${WORKDIR}/${P/_rc/-test}"

LICENSE="LGPL-2 GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86"
IUSE="+alsa avahi +caps jack lirc oss tcpd X hal dbus libsamplerate gnome bluetooth +asyncns +glib test"

RDEPEND="X? ( x11-libs/libX11[lib32?] x11-libs/libSM[lib32?] x11-libs/libICE[lib32?] x11-libs/libXtst[lib32?] )
	caps? ( sys-libs/libcap[lib32?] )
	libsamplerate? ( >=media-libs/libsamplerate-0.1.1-r1[lib32?] )
	alsa? ( >=media-libs/alsa-lib-1.0.19[lib32?] )
	glib? ( >=dev-libs/glib-2.4.0[lib32?] )
	avahi? ( >=net-dns/avahi-0.6.12[dbus,lib32?] )
	>=dev-libs/liboil-0.3.0[lib32?]
	jack? ( >=media-sound/jack-audio-connection-kit-0.100[lib32?] )
	tcpd? ( sys-apps/tcp-wrappers[lib32?] )
	lirc? ( app-misc/lirc[lib32?] )
	dbus? ( >=sys-apps/dbus-1.0.0[lib32?] )
	gnome? ( >=gnome-base/gconf-2.4.0[lib32?] )
	hal? (
		>=sys-apps/hal-0.5.7[lib32?]
		>=sys-apps/dbus-1.0.0[lib32?]
	)
	app-admin/eselect-esd
	bluetooth? (
		>=net-wireless/bluez-4[lib32?]
		>=sys-apps/dbus-1.0.0[lib32?]
	)
	asyncns? ( net-libs/libasyncns[lib32?] )
	>=media-libs/audiofile-0.2.6-r1[lib32?]
	>=media-libs/speex-1.2_beta[lib32?]
	>=media-libs/libsndfile-1.0.10[lib32?]
	>=dev-libs/liboil-0.3.6[lib32?]
	sys-libs/gdbm[lib32?]
	>=sys-devel/libtool-2.2.4[lib32?]" # it's a valid RDEPEND, libltdl.so is used

DEPEND="${RDEPEND}
	X? ( x11-proto/xproto )
	dev-libs/libatomic_ops[lib32?]
	dev-util/pkgconfig[lib32?]
	dev-util/intltool"

RDEPEND="${RDEPEND}
	gnome-extra/gnome-audio"

multilib-native_pkg_setup_internal() {
	enewgroup audio 18 # Just make sure it exists
	enewgroup realtime
	enewgroup pulse-access
	enewgroup pulse
	enewuser pulse -1 -1 /var/run/pulse pulse,audio
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${P}-bsd.patch"
	epatch "${FILESDIR}/${P}-CVE-2009-1894.patch"

	# The mix and resampler tests are broken in this release, because
	# they weren't updated for the 24-bit sample support; they are
	# fixed in 0.9.16 but I don't think it's worth backporting the
	# fixes. — flameeyes
	sed -i -e '/\(mix\|resampler\)-test/d' src/Makefile.am || die

	eautoreconf
	elibtoolize
}

multilib-native_src_configure_internal() {
	# To properly fix CVE-2008-0008
	append-flags -UNDEBUG

	append-ldflags $(no-as-needed)

	econf \
		--enable-largefile \
		$(use_enable glib glib2) \
		--disable-solaris \
		$(use_enable asyncns) \
		$(use_enable oss) \
		$(use_enable alsa) \
		$(use_enable lirc) \
		$(use_enable tcpd tcpwrap) \
		$(use_enable jack) \
		$(use_enable lirc) \
		$(use_enable avahi) \
		$(use_enable hal) \
		$(use_enable dbus) \
		$(use_enable gnome gconf) \
		$(use_enable libsamplerate samplerate) \
		$(use_enable bluetooth bluez) \
		--disable-polkit \
		$(use_enable X x11) \
		$(use_enable test default-build-tests) \
		$(use_with caps) \
		--localstatedir=/var \
		--with-realtime-group=realtime \
		--disable-per-user-esound-socket \
		|| die "econf failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"

	use avahi && sed -i -e '/module-zeroconf-publish/s:^#::' "${D}/etc/pulse/default.pa"

	dohtml -r doc
	dodoc README

	# Create the state directory
	diropts -o pulse -g pulse -m0755
	keepdir /var/run/pulse

	find "${D}" -name '*.la' -delete
}

multilib-native_pkg_postinst_internal() {
	elog "If you want to make use of realtime capabilities of PulseAudio"
	elog "you should follow the realtime guide to create and set up a realtime"
	elog "user group: http://www.gentoo.org/proj/en/desktop/sound/realtime.xml"
	elog "Make sure you also have baselayout installed with pam USE flag"
	elog "enabled, if you're using the rlimit method."
	if use bluetooth; then
		elog
		elog "The BlueTooth proximity module is not enabled in the default"
		elog "configuration file. If you do enable it, you'll have to have"
		elog "your BlueTooth controller enabled and inserted at bootup or"
		elog "PulseAudio will refuse to start."
		elog
		elog "Please note that the BlueTooth proximity module seems itself"
		elog "still experimental, so please report to upstream if you have"
		elog "problems with it."
	fi
	if use alsa; then
		local pkg="media-plugins/alsa-plugins"
		if has_version ${pkg} && ! has_version "${pkg}[pulseaudio]"; then
			elog
			elog "You have alsa support enabled so you probably want to install"
			elog "${pkg} with pulseaudio support to have"
			elog "alsa using applications route their sound through pulseaudio"
		fi
	fi

	eselect esd update --if-unset
}

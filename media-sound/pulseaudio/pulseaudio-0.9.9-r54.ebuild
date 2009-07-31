# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/pulseaudio/pulseaudio-0.9.9-r54.ebuild,v 1.1 2009/07/16 14:01:21 flameeyes Exp $

EAPI=2

inherit eutils libtool autotools flag-o-matic multilib-native

DESCRIPTION="A networked sound server with an advanced plugin system"
HOMEPAGE="http://www.pulseaudio.org"
SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.gz"

LICENSE="LGPL-2 GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86"
IUSE="alsa avahi caps jack lirc oss tcpd X hal dbus libsamplerate gnome bluetooth policykit asyncns"

RDEPEND="X? ( x11-libs/libX11[$(get_ml_usedeps)?] )
	caps? ( sys-libs/libcap[$(get_ml_usedeps)?] )
	>=media-libs/audiofile-0.2.6-r1[$(get_ml_usedeps)?]
	libsamplerate? ( >=media-libs/libsamplerate-0.1.1-r1[$(get_ml_usedeps)?] )
	>=media-libs/libsndfile-1.0.10[$(get_ml_usedeps)?]
	>=dev-libs/liboil-0.3.6[$(get_ml_usedeps)?]
	alsa? ( >=media-libs/alsa-lib-1.0.10[$(get_ml_usedeps)?] )
	>=dev-libs/glib-2.4.0[$(get_ml_usedeps)?]
	avahi? ( >=net-dns/avahi-0.6.12[$(get_ml_usedeps)?] )
	>=dev-libs/liboil-0.3.0[$(get_ml_usedeps)?]
	jack? ( >=media-sound/jack-audio-connection-kit-0.100[$(get_ml_usedeps)?] )
	tcpd? ( sys-apps/tcp-wrappers[$(get_ml_usedeps)?] )
	lirc? ( app-misc/lirc[$(get_ml_usedeps)?] )
	dbus? ( >=sys-apps/dbus-1.0.0[$(get_ml_usedeps)?] )
	gnome? ( >=gnome-base/gconf-2.4.0[$(get_ml_usedeps)?] )
	hal? (
		>=sys-apps/hal-0.5.7[$(get_ml_usedeps)?]
		>=sys-apps/dbus-1.0.0[$(get_ml_usedeps)?]
	)
	app-admin/eselect-esd
	bluetooth? (
		>=net-wireless/bluez-libs-3[$(get_ml_usedeps)?]
		>=sys-apps/dbus-1.0.0[$(get_ml_usedeps)?]
	)
	policykit? ( sys-auth/policykit[$(get_ml_usedeps)?] )
	asyncns? ( net-libs/libasyncns[$(get_ml_usedeps)?] )
	>=sys-devel/libtool-1.5.24[$(get_ml_usedeps)?]" # it's a valid RDEPEND, libltdl.so is used
DEPEND="${RDEPEND}
	dev-libs/libatomic_ops[$(get_ml_usedeps)?]
	dev-util/pkgconfig[$(get_ml_usedeps)?]"

# alsa-utils dep is for the alsasound init.d script (see bug #155707)
# bluez-utils dep is for the bluetooth init.d script
RDEPEND="${RDEPEND}
	gnome-extra/gnome-audio
	alsa? ( media-sound/alsa-utils )
	bluetooth? ( >=net-wireless/bluez-utils-3 )"

pkg_setup() {
	if use avahi && ! built_with_use net-dns/avahi dbus ; then
		echo
		eerror "In order to compile pulseaudio with avahi support, you need to have"
		eerror "net-dns/avahi emerged with 'dbus' in your USE flag. Please add that"
		eerror "flag, re-emerge avahi, and then emerge pulseaudio again."
		die "net-dns/avahi is missing the D-Bus bindings."
	fi

	enewgroup audio 18 # Just make sure it exists
	enewgroup realtime
	enewgroup pulse-access
	enewgroup pulse
	enewuser pulse -1 -1 /var/run/pulse pulse,audio
}

ml-native_src_prepare() {
	epatch "${FILESDIR}/${PN}-0.9.8-svn2074.patch"
	epatch "${FILESDIR}/${PN}-0.9.8-polkit.patch"
	epatch "${FILESDIR}/${PN}-0.9.8-bt-nohal.patch"
	epatch "${FILESDIR}/${PN}-0.9.8-esoundpath.patch"
	epatch "${FILESDIR}/${PN}-0.9.8-create-directory.patch"
	epatch "${FILESDIR}/${P}-CVE-2009-1894.patch"

	eautoreconf
	elibtoolize
}

ml-native_src_configure() {
	# To properly fix CVE-2008-0008
	append-flags -UNDEBUG

	econf \
		--enable-largefile \
		--enable-glib2 \
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
		$(use_enable policykit polkit) \
		$(use_with caps) \
		$(use_with X x) \
		--disable-ltdl-install \
		--localstatedir=/var \
		--with-realtime-group=realtime \
		|| die "econf failed"
}

ml-native_src_install() {
	emake -j1 DESTDIR="${D}" install || die "make install failed"

	newconfd "${FILESDIR}/pulseaudio.conf.d" pulseaudio

	local neededservices
	use alsa && neededservices="$neededservices alsasound"
	use avahi && neededservices="$neededservices avahi-daemon"
	use hal && neededservices="$neededservices hald"
	use bluetooth && neededservices="$neededservices bluetooth"
	[[ -n ${neededservices} ]] && sed -e "s/@neededservices@/need $neededservices/" "${FILESDIR}/pulseaudio.init.d-2" > "${T}/pulseaudio"
	doinitd "${T}/pulseaudio"

	use avahi && sed -i -e '/module-zeroconf-publish/s:^#::' "${D}/etc/pulse/default.pa"

	dohtml -r doc
	dodoc README

	# Create the state directory
	diropts -o pulse -g pulse -m0755
	keepdir /var/run/pulse
}

pkg_postinst() {
	elog "PulseAudio in Gentoo can use a system-wide pulseaudio daemon."
	elog "This support is enabled by starting the pulseaudio init.d ."
	elog "To be able to access that you need to be in the group pulse-access."
	elog "For more information about system-wide support, please refer to"
	elog "	 http://pulseaudio.org/wiki/SystemWideInstance"
	if use gnome; then
		elog
		elog "By enabling gnome USE flag, you enabled gconf support. Please note"
		elog "that you might need to remove the gnome USE flag or disable the"
		elog "gconf module on /etc/pulse/default.pa to be able to use PulseAudio"
		elog "with a system-wide instance."
	fi
	elog
	elog "To use the ESounD wrapper while using a system-wide daemon, you also"
	elog "need to enable auth-anonymous for the esound-unix module, or to copy"
	elog "/var/run/pulse/.esd_auth into each home directory."
	elog
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

	eselect esd update --if-unset
}

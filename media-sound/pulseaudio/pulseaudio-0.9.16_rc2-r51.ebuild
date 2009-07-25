# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/pulseaudio/pulseaudio-0.9.16_rc2-r51.ebuild,v 1.1 2009/07/16 14:00:05 flameeyes Exp $

EAPI=2

inherit eutils libtool flag-o-matic multilib-native

MY_P=${P/_rc/-test}

DESCRIPTION="A networked sound server with an advanced plugin system"
HOMEPAGE="http://www.pulseaudio.org/"
SRC_URI="http://0pointer.de/public/${MY_P}.tar.gz"

S="${WORKDIR}/${MY_P}"

LICENSE="LGPL-2 GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="alsa avahi caps jack lirc oss tcpd X hal dbus libsamplerate gnome bluetooth policykit asyncns +glib test doc"

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
		|| ( >=net-wireless/bluez-4[lib32?]
			 >=net-wireless/bluez-libs-3[lib32?] )
		>=sys-apps/dbus-1.0.0[lib32?]
	)
	policykit? ( sys-auth/policykit[lib32?] )
	asyncns? ( net-libs/libasyncns[lib32?] )
	>=media-libs/audiofile-0.2.6-r1[lib32?]
	>=media-libs/speex-1.2_beta[lib32?]
	>=media-libs/libsndfile-1.0.10[lib32?]
	>=dev-libs/liboil-0.3.6[lib32?]
	sys-libs/gdbm[lib32?]
	>=sys-devel/libtool-2.2.4[lib32?]" # it's a valid RDEPEND, libltdl.so is used

DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	X? ( x11-proto/xproto )
	dev-libs/libatomic_ops[lib32?]
	dev-util/pkgconfig[lib32?]
	|| ( dev-util/unifdef sys-freebsd/freebsd-ubin )
	dev-util/intltool"

# alsa-utils dep is for the alsasound init.d script (see bug #155707)
# bluez-utils dep is for the bluetooth init.d script
RDEPEND="${RDEPEND}
	sys-apps/openrc
	gnome-extra/gnome-audio
	alsa? ( media-sound/alsa-utils )
	bluetooth? (
	|| ( >=net-wireless/bluez-4
		 >=net-wireless/bluez-utils-3 ) )"

pkg_setup() {
	enewgroup audio 18 # Just make sure it exists
	enewgroup pulse-access
	enewgroup pulse
	enewuser pulse -1 -1 /var/run/pulse pulse,audio
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${PN}-0.9.16-CVE-2009-1894.patch"
	elibtoolize
}

multilib-native_src_configure_internal() {
	# To properly fix CVE-2008-0008
	append-flags -UNDEBUG

	# It's a binutils bug, once I can find time to fix that I'll add a
	# proper dependency and fix this up. — flameeyes
	append-ldflags -Wl,--no-as-needed

	# udev is disabled because we don't have the right version just
	# yet, and thus we need to avoid it for now. Once we have the
	# version I'll revbump PA. — flameeyes
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
		$(use_enable X x11) \
		$(use_enable test default-build-tests) \
		$(use_with caps) \
		--disable-udev \
		--localstatedir=/var \
		--disable-per-user-esound-socket \
		--with-database=gdbm \
		|| die "econf failed"

	if use doc; then
		pushd doxygen
		doxygen doxygen.conf || die
		popd
	fi
}

multilib-native_src_install_internal() {
	emake -j1 DESTDIR="${D}" install || die "make install failed"

	newconfd "${FILESDIR}/pulseaudio.conf.d" pulseaudio

	use_define() {
		local define=${2:-$(echo $1 | tr '[:lower:]' '[:upper:]')}

		use "$1" && echo "-D$define" || echo "-U$define"
	}

	unifdef $(use_define hal) \
		$(use_define avahi) \
		$(use_define alsa) \
		$(use_define bluetooth) \
		"${FILESDIR}/pulseaudio.init.d-4" \
		> "${T}/pulseaudio"

	doinitd "${T}/pulseaudio"

	use avahi && sed -i -e '/module-zeroconf-publish/s:^#::' "${D}/etc/pulse/default.pa"

	# the “true” condition should be replaced by “use udev” once
	# that's enabled.
	if use hal && true; then
		sed -i -e 's:-udev:-hal:' "${D}/etc/pulse/default.pa" || die
	fi

	dodoc README ChangeLog todo || die

	if use doc; then
		pushd doxygen/html
		dohtml * || die
		popd
	fi

	# Create the state directory
	diropts -o pulse -g pulse -m0755
	keepdir /var/run/pulse

	find "${D}" -name '*.la' -delete
}

pkg_postinst() {
	elog "PulseAudio in Gentoo can use a system-wide pulseaudio daemon."
	elog "This support is enabled by starting the pulseaudio init.d ."
	elog "To be able to access that you need to be in the group pulse-access."
	elog "If you choose to use this feature, please make sure that you"
	elog "really want to run PulseAudio this way:"
	elog "   http://pulseaudio.org/wiki/WhatIsWrongWithSystemMode"
	elog "For more information about system-wide support, please refer to:"
	elog "	 http://pulseaudio.org/wiki/SystemWideInstance"
	if use gnome; then
		elog
		elog "By enabling gnome USE flag, you enabled gconf support. Please note"
		elog "that you might need to remove the gnome USE flag or disable the"
		elog "gconf module on /etc/pulse/system.pa to be able to use PulseAudio"
		elog "with a system-wide instance."
	fi
	elog
	elog "To use the ESounD wrapper while using a system-wide daemon, you also"
	elog "need to enable auth-anonymous for the esound-unix module, or to copy"
	elog "/var/run/pulse/.esd_auth into each home directory."
	elog
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
		if has_version ${pkg} && ! built_with_use --missing false ${pkg} pulseaudio; then
			elog
			elog "You have alsa support enabled so you probably want to install"
			elog "${pkg} with pulseaudio support to have"
			elog "alsa using applications route their sound through pulseaudio"
		fi
	fi

	eselect esd update --if-unset
}

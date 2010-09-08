# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/bluez/bluez-4.70.ebuild,v 1.2 2010/09/07 15:06:33 jer Exp $

EAPI="2"

inherit multilib eutils multilib-native

DESCRIPTION="Bluetooth Tools and System Daemons for Linux"
HOMEPAGE="http://bluez.sourceforge.net/"
SRC_URI="mirror://kernel/linux/bluetooth/${P}.tar.gz"
LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86"

IUSE="alsa attrib caps +consolekit cups debug gstreamer maemo6 old-daemons pcmcia pnat test-programs usb"

CDEPEND="alsa? (
		media-libs/alsa-lib[alsa_pcm_plugins_extplug,alsa_pcm_plugins_ioplug,lib32?]
	)
	caps? ( >=sys-libs/libcap-ng-0.6.2[lib32?] )
	gstreamer? (
		>=media-libs/gstreamer-0.10[lib32?]
		>=media-libs/gst-plugins-base-0.10[lib32?] )
	usb? ( dev-libs/libusb[lib32?] )
	cups? ( net-print/cups[lib32?] )
	>=sys-fs/udev-146[extras,lib32?]
	>=dev-libs/glib-2.14[lib32?]
	sys-apps/dbus[lib32?]
	media-libs/libsndfile[lib32?]
	>=dev-libs/libnl-1.1[lib32?]
	!net-wireless/bluez-libs
	!net-wireless/bluez-utils"
DEPEND="sys-devel/flex[lib32?]
	>=dev-util/pkgconfig-0.20[lib32?]
	${CDEPEND}"
RDEPEND="${CDEPEND}
	consolekit? ( sys-auth/pambase[consolekit] )
	test-programs? (
		dev-python/dbus-python[lib32?]
		dev-python/pygobject[lib32?] )"

multilib-native_pkg_setup_internal() {
	if ! use consolekit; then
		enewgroup plugdev
	fi
}

multilib-native_src_prepare_internal() {
	if ! use consolekit; then
		# No consolekit for at_console etc, so we grant plugdev the rights
		epatch	"${FILESDIR}/bluez-plugdev.patch"
	fi

	if use cups; then
		epatch "${FILESDIR}/4.60/cups-location.patch"
	fi
}

multilib-native_src_configure_internal() {
	econf \
		$(use_enable caps capng) \
		--enable-network \
		--enable-serial \
		--enable-input \
		--enable-audio \
		--enable-service \
		$(use_enable gstreamer) \
		$(use_enable alsa) \
		$(use_enable usb) \
		--enable-netlink \
		--enable-tools \
		--enable-bccmd \
		--enable-dfutool \
		$(use_enable old-daemons hidd) \
		$(use_enable old-daemons pand) \
		$(use_enable old-daemons dund) \
		$(use_enable attrib) \
		$(use_enable pnat) \
		$(use_enable maemo6) \
		$(use_enable cups) \
		$(use_enable test-programs test) \
		--enable-udevrules \
		--enable-configfiles \
		$(use_enable pcmcia) \
		$(use_enable debug) \
		--localstatedir=/var
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc AUTHORS ChangeLog README || die

	if use test-programs ; then
		cd "${S}/test"
		dobin simple-agent simple-service monitor-bluetooth
		newbin list-devices list-bluetooth-devices
		for b in apitest hsmicro hsplay test-* ; do
			newbin "${b}" "bluez-${b}"
		done
		insinto /usr/share/doc/${PF}/test-services
		doins service-*

		cd "${S}"
	fi

	if use old-daemons; then
		newconfd "${FILESDIR}/4.18/conf.d-hidd" hidd || die
		newinitd "${FILESDIR}/init.d-hidd" hidd || die
	fi

	insinto /etc/bluetooth
	doins \
		input/input.conf \
		audio/audio.conf \
		network/network.conf \
		serial/serial.conf \
		|| die

	insinto /etc/udev/rules.d/
	newins "${FILESDIR}/${PN}-4.18-udev.rules" 70-bluetooth.rules || die
	exeinto /$(get_libdir)/udev/
	newexe "${FILESDIR}/${PN}-4.18-udev.script" bluetooth.sh || die

	newinitd "${FILESDIR}/bluetooth-init.d" bluetooth || die
	newconfd "${FILESDIR}/4.60/bluetooth-conf.d" bluetooth || die
}

multilib-native_pkg_postinst_internal() {
	udevadm control --reload-rules && udevadm trigger --subsystem-match=bluetooth

	elog
	elog "To use dial up networking you must install net-dialup/ppp."
	elog
	elog "For a password agent, there is for example net-wireless/bluez-gnome"
	elog "for gnome and net-wireless/kdebluetooth for kde. You can also give a"
	elog "try to net-wireless/blueman"
	elog
	elog "Use the old-daemons use flag to get the old daemons like hidd"
	elog "installed. Please note that the init script doesn't stop the old"
	elog "daemons after you update it so it's recommended to run:"
	elog "  /etc/init.d/bluetooth stop"
	elog "before updating your configuration files or you can manually kill"
	elog "the extra daemons you previously enabled in /etc/conf.d/bluetooth."

	if use consolekit; then
		elog ""
		elog "If you want to use rfcomm as a normal user, you need to add the user"
		elog "to the uucp group."
	else
		elog ""
		elog "Since you have the consolekit use flag disabled, you will only be able to run"
		elog "bluetooth clients as root. If you want to be able to run bluetooth clientes as "
		elog "a regular user, you need to enable the consolekit use flag for this package or"
		elog "to add the user to the plugdev group."
	fi

	if use old-daemons; then
		elog ""
		elog "The hidd init script was installed because you have the old-daemons"
		elog "use flag on. It is not started by default via udev so please add it"
		elog "to the required runlevels using rc-update <runlevel> add hidd. If"
		elog "you need init scripts for the other daemons, please file requests"
		elog "to https://bugs.gentoo.org."
	fi
}

# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/bluez/bluez-4.82.ebuild,v 1.3 2011/02/02 01:22:24 jer Exp $

EAPI="3"

inherit multilib eutils multilib-native

DESCRIPTION="Bluetooth Tools and System Daemons for Linux"
HOMEPAGE="http://www.bluez.org/"

OUIDATE="20101219" # Needed because of bug #345263
SRC_URI="mirror://kernel/linux/bluetooth/${P}.tar.gz
	http://standards.ieee.org/regauth/oui/oui.txt -> oui-${OUIDATE}.txt"
LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 ~arm hppa ~ppc ~ppc64 ~x86"

IUSE="alsa attrib caps +consolekit cups debug gstreamer maemo6 health old-daemons pcmcia pnat test-programs usb"

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
		sed -i -e "s:cupsdir = \$(libdir)/cups:cupsdir = `cups-config --serverbin`:" \
			Makefile.tools Makefile.in || die
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
		--enable-tools \
		--enable-bccmd \
		--enable-dfutool \
		$(use_enable old-daemons hidd) \
		$(use_enable old-daemons pand) \
		$(use_enable old-daemons dund) \
		$(use_enable attrib) \
		$(use_enable health) \
		$(use_enable pnat) \
		$(use_enable maemo6) \
		$(use_enable cups) \
		$(use_enable test-programs test) \
		--enable-udevrules \
		--enable-configfiles \
		$(use_enable pcmcia) \
		$(use_enable debug) \
		--localstatedir=/var \
		--disable-hal
}

multilib-native_src_install_internal() {
	emake DESTDIR="${ED}" install || die "make install failed"

	dodoc AUTHORS ChangeLog README || die

	if use test-programs ; then
		cd "${S}/test"
		dobin simple-agent simple-service monitor-bluetooth || die
		newbin list-devices list-bluetooth-devices || die
		for b in apitest hsmicro hsplay test-* ; do
			newbin "${b}" "bluez-${b}" || die
		done
		insinto /usr/share/doc/${PF}/test-services
		doins service-* || die

		cd "${S}"
	fi

	if use old-daemons; then
		newconfd "${FILESDIR}/4.18/conf.d-hidd" hidd || die
		newinitd "${FILESDIR}/init.d-hidd" hidd || die
		newconfd "${FILESDIR}/conf.d-dund" dund || die
		newinitd "${FILESDIR}/init.d-dund" dund || die
	fi

	insinto /etc/bluetooth
	doins \
		input/input.conf \
		audio/audio.conf \
		network/network.conf \
		serial/serial.conf \
		|| die

	insinto /$(get_libdir)/udev/rules.d/
	newins "${FILESDIR}/${PN}-4.18-udev.rules" 70-bluetooth.rules || die
	exeinto /$(get_libdir)/udev/
	newexe "${FILESDIR}/${PN}-4.18-udev.script" bluetooth.sh || die

	newinitd "${FILESDIR}/bluetooth-init.d" bluetooth || die
	newconfd "${FILESDIR}/4.60/bluetooth-conf.d" bluetooth || die

	# Install oui.txt as requested in bug #283791 and approved by upstream
	insinto /var/lib/misc
	newins "${DISTDIR}/oui-${OUIDATE}.txt" oui.txt || die

	find "${ED}" -name "*.la" -delete || die "remove of la files failed"
}

multilib-native_pkg_postinst_internal() {
	udevadm control --reload-rules && udevadm trigger --subsystem-match=bluetooth

	if ! has_version "net-dialup/ppp"; then
		elog
		elog "To use dial up networking you must install net-dialup/ppp."
	fi

	if ! has_version "net-wireless/gnome-bluetooth" && ! has_version "net-wireless/kbluetooth"; then
		elog
		elog "For desktop integration you can try net-wireless/gnome-bluetooth"
		elog "for gnome and net-wireless/kbluetooth for kde."
	fi

	if ! use old-daemons; then
		elog
		elog "Use the old-daemons use flag to get the old daemons like hidd or pand"
		elog "installed. Please note that 'bluetooth' init script doesn't stop the old"
		elog "daemons after you update it, so it's recommended to stop all of them using"
		elog "their own init scripts or manually killing them."
	fi

	if use consolekit; then
		elog
		elog "If you want to use rfcomm as a normal user, you need to add the user"
		elog "to the uucp group."
	else
		elog
		elog "Since you have the consolekit use flag disabled, you will only be able to run"
		elog "bluetooth clients as root. If you want to be able to run bluetooth clientes as "
		elog "a regular user, you need to enable the consolekit use flag for this package or"
		elog "to add the user to the plugdev group."
	fi

	if use old-daemons; then
		elog
		elog "dund and hidd init scripts were installed because you have the old-daemons"
		elog "use flag on. They are not started by default via udev so please add them"
		elog "to the required runlevels using rc-update <runlevel> add <dund/hidd>. If"
		elog "you need init scripts for the other daemons, please file requests"
		elog "to https://bugs.gentoo.org."
	fi
}

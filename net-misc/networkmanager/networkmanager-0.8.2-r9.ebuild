# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/networkmanager/networkmanager-0.8.2-r9.ebuild,v 1.1 2011/02/26 08:13:31 qiaomuf Exp $

EAPI="2"

inherit autotools eutils gnome.org linux-info multilib-native

# NetworkManager likes itself with capital letters
MY_PN=${PN/networkmanager/NetworkManager}
MY_P=${MY_PN}-${PV}

DESCRIPTION="Network configuration and management in an easy way. Desktop environment independent."
HOMEPAGE="http://www.gnome.org/projects/NetworkManager/"
SRC_URI="${SRC_URI//${PN}/${MY_PN}}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86"
IUSE="avahi bluetooth doc nss gnutls dhclient dhcpcd kernel_linux resolvconf connection-sharing"

RDEPEND=">=sys-apps/dbus-1.2[lib32?]
	>=dev-libs/dbus-glib-0.75[lib32?]
	>=net-wireless/wireless-tools-28_pre9
	>=sys-fs/udev-145[extras,lib32?]
	>=dev-libs/glib-2.18[lib32?]
	>=sys-auth/polkit-0.92[lib32?]
	>=dev-libs/libnl-1.1[lib32?]
	>=net-misc/modemmanager-0.4
	>=net-wireless/wpa_supplicant-0.5.10[dbus]
	bluetooth? ( net-wireless/bluez[lib32?] )
	|| ( sys-libs/e2fsprogs-libs[lib32?] <sys-fs/e2fsprogs-1.41.0[lib32?] )
	avahi? ( net-dns/avahi[autoipd,lib32?] )
	gnutls? (
		nss? ( >=dev-libs/nss-3.11[lib32?] )
		!nss? ( dev-libs/libgcrypt[lib32?]
			net-libs/gnutls[lib32?] ) )
	!gnutls? ( >=dev-libs/nss-3.11[lib32?] )
	dhclient? (
		dhcpcd? ( >=net-misc/dhcpcd-4.0.0_rc3 )
		!dhcpcd? ( net-misc/dhcp ) )
	!dhclient? ( >=net-misc/dhcpcd-4.0.0_rc3 )
	resolvconf? ( net-dns/openresolv )
	connection-sharing? (
		net-dns/dnsmasq
		net-firewall/iptables )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	dev-util/intltool
	>=net-dialup/ppp-2.4.5
	doc? ( >=dev-util/gtk-doc-1.8 )"

S=${WORKDIR}/${MY_P}

sysfs_deprecated_check() {
	ebegin "Checking for SYSFS_DEPRECATED support"

	if { linux_chkconfig_present SYSFS_DEPRECATED_V2; }; then
		eerror "Please disable SYSFS_DEPRECATED_V2 support in your kernel config and recompile your kernel"
		eerror "or NetworkManager will not work correctly."
		eerror "See http://bugs.gentoo.org/333639 for more info."
		die "CONFIG_SYSFS_DEPRECATED_V2 support detected!"
	fi
	eend $?
}

multilib-native_pkg_setup_internal() {
	# FIXME. Required by -confchanges.patch, but the patch is invalid as
	# ConsoleKit and PolicyKit is enough to get authorization.
	enewgroup plugdev

	if use kernel_linux; then
		get_version
		if linux_config_exists; then
			sysfs_deprecated_check
		else
			ewarn "Was unable to determine your kernel .config"
			ewarn "Please note that if CONFIG_SYSFS_DEPRECATED_V2 is set in your kernel .config, NetworkManager will not work correctly."
			ewarn "See http://bugs.gentoo.org/333639 for more info."
		fi

	fi
}

multilib-native_src_prepare_internal() {
	# dbus policy patch
	epatch "${FILESDIR}/${P}-confchanges.patch"
	# accept "gw" in /etc/conf.d/net (bug #339215)
	epatch "${FILESDIR}/${P}-accept-gw.patch"
	# fix shared connection wrt bug #350476
	# fix parsing dhclient.conf wrt bug #352638
	epatch "${FILESDIR}/${P}-shared-connection.patch"
	# Backports #1
	epatch "${FILESDIR}/${P}-1.patch"
	# won't crash upon startup for 32bit machines wrt bug #353807
	epatch "${FILESDIR}/${P}-fix-timestamp.patch"
	# fix tests wrt bug #353549
	epatch "${FILESDIR}/${P}-fix-tests.patch"
	# fix temporary files creation bug #349003
	epatch "${FILESDIR}/${P}-fix-tempfiles.patch"
	# won't write when nothing changed (bug #356339)
	epatch "${FILESDIR}/${P}-ifnet-smarter-write.patch"
	eautoreconf
}

multilib-native_src_configure_internal() {
	ECONF="--disable-more-warnings
		--localstatedir=/var
		--with-distro=gentoo
		--with-dbus-sys-dir=/etc/dbus-1/system.d
		--with-udev-dir=/etc/udev
		--with-iptables=/sbin/iptables
		$(use_enable doc gtk-doc)
		$(use_with doc docs)
		$(use_with resolvconf)"

	# default is dhcpcd (if none or both are specified), ISC dchclient otherwise
	if use dhclient ; then
		if use dhcpcd ; then
			ECONF="${ECONF} --with-dhcpcd --without-dhclient"
		else
			ECONF="${ECONF} --with-dhclient --without-dhcpcd"
		fi
	else
		ECONF="${ECONF} --with-dhcpcd --without-dhclient"
	fi

	# default is NSS (if none or both are specified), GnuTLS otherwise
	if use gnutls ; then
		if use nss ; then
			ECONF="${ECONF} --with-crypto=nss"
		else
			ECONF="${ECONF} --with-crypto=gnutls"
		fi
	else
		ECONF="${ECONF} --with-crypto=nss"
	fi

	econf ${ECONF}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# Need to keep the /var/run/NetworkManager directory
	keepdir /var/run/NetworkManager

	# Need to keep the /etc/NetworkManager/dispatched.d for dispatcher scripts
	keepdir /etc/NetworkManager/dispatcher.d

	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed"

	# Add keyfile plugin support
	keepdir /etc/NetworkManager/system-connections
	insinto /etc/NetworkManager
	newins "${FILESDIR}/nm-system-settings.conf-ifnet" nm-system-settings.conf \
		|| die "newins failed"
}

multilib-native_pkg_postinst_internal() {
	elog "You will need to reload DBus if this is your first time installing"
	elog "NetworkManager, or if you're upgrading from 0.7 or older."
	elog ""
}

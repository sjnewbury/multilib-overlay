# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/networkmanager/networkmanager-0.8-r1.ebuild,v 1.5 2010/08/13 07:15:33 fauli Exp $

EAPI="2"

inherit gnome.org eutils multilib-native

# NetworkManager likes itself with capital letters
MY_PN=${PN/networkmanager/NetworkManager}
MY_P=${MY_PN}-${PV}

DESCRIPTION="Network configuration and management in an easy way. Desktop environment independent."
HOMEPAGE="http://www.gnome.org/projects/NetworkManager/"
SRC_URI="${SRC_URI//${PN}/${MY_PN}}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 x86"
IUSE="avahi bluetooth doc nss gnutls dhclient dhcpcd resolvconf connection-sharing"

RDEPEND=">=sys-apps/dbus-1.2[lib32?]
	>=dev-libs/dbus-glib-0.75[lib32?]
	>=net-wireless/wireless-tools-28_pre9
	>=sys-fs/udev-145[extras,lib32?]
	>=dev-libs/glib-2.18[lib32?]
	>=sys-auth/polkit-0.92[lib32?]
	>=dev-libs/libnl-1.1[lib32?]
	>=net-misc/modemmanager-0.2
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
		!dhcpcd? ( >=net-misc/dhcp-3.0.0 ) )
	!dhclient? ( >=net-misc/dhcpcd-4.0.0_rc3 )
	resolvconf? ( net-dns/openresolv )
	connection-sharing? (
		net-dns/dnsmasq
		net-firewall/iptables )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	dev-util/intltool
	net-dialup/ppp
	doc? ( >=dev-util/gtk-doc-1.8 )"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	# Fix up the dbus conf file to use plugdev group
	epatch "${FILESDIR}/${PN}-0.8-confchanges.patch"

	# Hack keyfile plugin to read hostname file, fixes bug 176873
	epatch "${FILESDIR}/${P}-read-hostname.patch"

	# Clear NSCD cache rather then kill daemon bug 301720
	epatch "${FILESDIR}/${P}-nscd-clear-cache.patch"
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
			ECONF="${ECONF} --with-dhcp-client=dhcpcd"
		else
			ECONF="${ECONF} --with-dhcp-client=dhclient"
		fi
	else
		ECONF="${ECONF} --with-dhcp-client=dhcpcd"
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
	newins "${FILESDIR}/nm-system-settings.conf" nm-system-settings.conf \
		|| die "newins failed"
}

multilib-native_pkg_postinst_internal() {
	elog "You will need to reload DBus if this is your first time installing"
	elog "NetworkManager, or if you're upgrading from 0.7 or older."
	elog ""
}

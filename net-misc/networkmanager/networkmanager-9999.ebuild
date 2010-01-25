# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/networkmanager/networkmanager-0.8.0_pre20091105.ebuild,v 1.2 2009/11/05 15:52:12 dagger Exp $

EAPI="2"
inherit eutils autotools git multilib-native

# NetworkManager likes itself with capital letters
MY_PN=${PN/networkmanager/NetworkManager}
MY_P=${MY_PN}-${PV}

DESCRIPTION="Network configuration and management in an easy way. Desktop environment independent."
HOMEPAGE="http://www.gnome.org/projects/NetworkManager/"
#SRC_URI="http://dev.gentoo.org/~dagger/files/${MY_P}.tar.bz2"
SRC_URI=""
EGIT_REPO_URI="git://anongit.freedesktop.org/${MY_PN}/${MY_PN}.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="avahi bluetooth doc nss gnutls dhclient dhcpcd resolvconf connection-sharing"

RDEPEND=">=sys-apps/dbus-1.2[lib32?]
	>=dev-libs/dbus-glib-0.75[lib32?]
	>=net-wireless/wireless-tools-28_pre9
	>=sys-fs/udev-145[extras,lib32?]
	>=dev-libs/glib-2.16[lib32?]
	>=sys-auth/polkit-0.92[lib32?]
	>=dev-libs/libnl-1.1[lib32?]
	>=net-misc/modemmanager-0.2
	>=net-wireless/wpa_supplicant-0.5.10[dbus]
	bluetooth? ( net-wireless/bluez )
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
	>=dev-util/gtk-doc-1.8"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {

	# Fix up the dbus conf file to use plugdev group
	epatch "${FILESDIR}/${PN}-0.7.1-confchanges.patch"
	gtkdocize
	intltoolize
	eautoreconf
}

multilib-native_src_configure_internal() {
	ECONF="--disable-more-warnings
		--localstatedir=/var
		--with-distro=gentoo
		--with-dbus-sys-dir=/etc/dbus-1/system.d
		$(use_enable doc gtk-doc)
		$(use_with doc docs)
		$(use_with resolvconf)
		$(use_with connection-sharing iptables)"

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
	insinto /etc/udev/rules.d
	newins callouts/77-nm-probe-modem-capabilities.rules 77-nm-probe-modem-capabilities.rules
	rm -rf "${D}"/lib/udev/rules.d
}

pkg_postinst() {
	elog "You will need to restart DBUS if this is your first time"
	elog "installing NetworkManager."
	elog ""
	elog "To save system-wide settings as a user, that user needs to have the"
	elog "right policykit privileges. You can add them by running:"
	elog 'polkit-auth --grant org.freedesktop.network-manager-settings.system.modify --user "USERNAME"'
}

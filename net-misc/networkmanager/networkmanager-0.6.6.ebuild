# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/networkmanager/networkmanager-0.6.6.ebuild,v 1.6 2009/04/22 13:30:43 rbu Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

# NetworkManager likes itself with capital letters
MY_P=${P/networkmanager/NetworkManager}

DESCRIPTION="Network configuration and management in an easy way. Desktop environment independent."
HOMEPAGE="http://www.gnome.org/projects/NetworkManager/"
# Release candidate for 0.6.6, Hosted in dcbw's redhat space.
SRC_URI="http://people.redhat.com/dcbw/NetworkManager/0.6.6/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE="crypt doc gnome"

# Yes, I know that configure will accept libnl 1.0-pre8, however we only have
# 1.1 in the tree, therefore dep on it.
RDEPEND=">=sys-apps/dbus-0.60[lib32?]
	>=sys-apps/hal-0.5.10[lib32?]
	sys-apps/iproute2
	>=dev-libs/libnl-1.1[lib32?]
	>=net-misc/dhcdbd-1.4
	>=net-wireless/wireless-tools-28_pre9
	>=net-wireless/wpa_supplicant-0.4.8
	>=dev-libs/glib-2.8[lib32?]
	gnome? ( >=x11-libs/gtk+-2.8[lib32?]
		>=gnome-base/libglade-2[lib32?]
		>=gnome-base/gnome-keyring-0.4[lib32?]
		>=gnome-base/gconf-2[lib32?]
		>=gnome-base/libgnomeui-2[lib32?] )
	crypt? ( dev-libs/libgcrypt[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	dev-util/intltool"
PDEPEND="gnome? ( >gnome-extra/nm-applet-0.6.5 )"

DOCS="AUTHORS ChangeLog NEWS README"
USE_DESTDIR="1"

G2CONF="${G2CONF} \
	`use_with crypt gcrypt` \
	`use_with gnome` \
	--disable-more-warnings \
	--localstatedir=/var \
	--with-distro=gentoo \
	--with-dbus-sys=/etc/dbus-1/system.d"

S=${WORKDIR}/${MY_P}

multilib-native_pkg_setup_internal() {
	if built_with_use sys-apps/iproute2 minimal ; then
		eerror "Please rebuild sys-apps/iproute2 without the minimal useflag."
		die "Fix iproute2 first."
	fi
}

multilib-native_src_prepare_internal() {
	# Use the kernel headers
	epatch "${FILESDIR}/${PN}-use-kernel-headers.patch"
	# Fix the resolv.conf permissions
	epatch "${FILESDIR}/${PN}-resolvconf-perms.patch"
	# Fix up the dbus conf file to use plugdev group
	epatch "${FILESDIR}/${PN}-0.6.5-confchanges.patch"
}

multilib-native_src_install_internal() {
	gnome2_src_install
	# Need to keep the /var/run/NetworkManager directory
	keepdir /var/run/NetworkManager
}

multilib-native_pkg_postinst_internal() {
	gnome2_icon_cache_update
	elog "You need to be in the plugdev group in order to use NetworkManager"
	elog "Problems with your hostname getting changed?"
	elog ""
	elog "Add the following to /etc/dhcp/dhclient.conf"
	elog 'send host-name "YOURHOSTNAME";'
	elog 'supersede host-name "YOURHOSTNAME";'

	elog "You will need to restart DBUS if this is your first time"
	elog "installing NetworkManager."
}

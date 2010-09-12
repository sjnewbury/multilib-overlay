# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gvfs/gvfs-1.6.3.ebuild,v 1.5 2010/09/11 18:42:33 josejx Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools bash-completion gnome2 eutils multilib-native

DESCRIPTION="GNOME Virtual Filesystem Layer"
HOMEPAGE="http://www.gnome.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~ia64 ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd"
IUSE="archive avahi bluetooth cdda doc fuse gdu gnome gnome-keyring gphoto2 hal
+http iphone samba +udev"

RDEPEND=">=dev-libs/glib-2.23.4[lib32?]
	>=sys-apps/dbus-1.0[lib32?]
	dev-libs/libxml2[lib32?]
	net-misc/openssh[lib32?]
	>=sys-fs/udev-138[lib32?]
	archive? ( app-arch/libarchive[lib32?] )
	avahi? ( >=net-dns/avahi-0.6[lib32?] )
	bluetooth? (
		>=app-mobilephone/obex-data-server-0.4.5
		dev-libs/dbus-glib[lib32?]
		net-wireless/bluez[lib32?]
		dev-libs/expat[lib32?] )
	fuse? ( sys-fs/fuse[lib32?] )
	gdu? ( >=sys-apps/gnome-disk-utility-2.29[lib32?] )
	gnome? ( >=gnome-base/gconf-2.0[lib32?] )
	gnome-keyring? ( >=gnome-base/gnome-keyring-1.0[lib32?] )
	gphoto2? ( >=media-libs/libgphoto2-2.4.7[lib32?] )
	iphone? ( app-pda/libimobiledevice )
	udev? (
		cdda? ( >=dev-libs/libcdio-0.78.2[-minimal,lib32?] )
		>=sys-fs/udev-145[extras,lib32?] )
	hal? (
		cdda? ( >=dev-libs/libcdio-0.78.2[-minimal,lib32?] )
		>=sys-apps/hal-0.5.10[lib32?] )
	http? ( >=net-libs/libsoup-gnome-2.26.0[lib32?] )
	samba? ( || ( >=net-fs/samba-3.4.6[smbclient,lib32?]
			<=net-fs/samba-3.3[lib32?] ) )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.19[lib32?]
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

multilib-native_pkg_setup_internal() {
	if use cdda && ! use hal && ! use udev; then
		ewarn "You have \"+cdda\", but you have \"-hal\" and \"-udev\""
		ewarn "cdda support will NOT be built unless you enable EITHER hal OR udev"
	fi

	G2CONF="${G2CONF}
		--enable-udev
		--disable-bash-completion
		--with-dbus-service-dir=/usr/share/dbus-1/services
		$(use_enable archive)
		$(use_enable avahi)
		$(use_enable bluetooth obexftp)
		$(use_enable cdda)
		$(use_enable fuse)
		$(use_enable gdu)
		$(use_enable gnome gconf)
		$(use_enable gphoto2)
		$(use_enable iphone afc)
		$(use_enable udev gudev)
		$(use_enable hal)
		$(use_enable http)
		$(use_enable gnome-keyring keyring)
		$(use_enable samba)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Conditional patching purely to avoid eautoreconf
	use gphoto2 && epatch "${FILESDIR}/${PN}-1.2.2-gphoto2-stricter-checks.patch"

	if use archive; then
		epatch "${FILESDIR}/${PN}-1.2.2-expose-archive-backend.patch"
		echo "mount-archive.desktop.in" >> po/POTFILES.in
		echo "mount-archive.desktop.in.in" >> po/POTFILES.in
	fi

	use gphoto2 || use archive && eautoreconf
}

multilib-native_src_install_internal() {
	gnome2_src_install
	use bash-completion && \
		dobashcompletion programs/gvfs-bash-completion.sh ${PN}
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst
	use bash-completion && bash-completion_pkg_postinst

	ewarn "In order to use the new gvfs services, please reload dbus configuration"
	ewarn "You may need to log out and log back in for some changes to take effect"
}

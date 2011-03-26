# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/gnome-disk-utility/gnome-disk-utility-2.32.0-r1.ebuild,v 1.8 2011/03/22 19:45:54 ranger Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit autotools eutils gnome2 multilib-native

DESCRIPTION="Disk Utility for GNOME using devicekit-disks"
HOMEPAGE="http://git.gnome.org/cgit/gnome-disk-utility/"
SRC_URI="http://hal.freedesktop.org/releases/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sh sparc x86"
IUSE="avahi doc fat gnome-keyring nautilus remote-access"

CDEPEND="
	>=dev-libs/glib-2.22:2[lib32?]
	>=dev-libs/dbus-glib-0.74[lib32?]
	>=dev-libs/libunique-1:1[lib32?]
	>=x11-libs/gtk+-2.20:2[lib32?]
	=sys-fs/udisks-1.0*[remote-access?]
	>=dev-libs/libatasmart-0.14[lib32?]
	>=x11-libs/libnotify-0.3[lib32?]
	avahi? ( >=net-dns/avahi-0.6.25[gtk,lib32?] )
	gnome-keyring? ( || (
		gnome-base/libgnome-keyring[lib32?]
		<gnome-base/gnome-keyring-2.29.4[lib32?] ) )
	nautilus? ( >=gnome-base/nautilus-2.24[lib32?] )
"
RDEPEND="${CDEPEND}
	x11-misc/xdg-utils
	fat? ( sys-fs/dosfstools )
	!!sys-apps/udisks"
DEPEND="${CDEPEND}
	sys-devel/gettext[lib32?]
	gnome-base/gnome-common
	app-text/docbook-xml-dtd:4.1.2
	app-text/scrollkeeper
	app-text/gnome-doc-utils[lib32?]

	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.35
	>=dev-util/gtk-doc-am-1.13

	doc? ( >=dev-util/gtk-doc-1.3 )"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-static
		$(use_enable avahi avahi-ui)
		$(use_enable nautilus)
		$(use_enable remote-access)
		$(use_enable gnome-keyring)"
	DOCS="AUTHORS NEWS README TODO"
}

multilib-native_src_prepare_internal() {
	sed -i \
		-e '/printf/s:nautilus:xdg-open:' \
		src/palimpsest/gdu-section-volumes.c || die #350919

	# Keep avahi optional, upstream bug #631986
	epatch "${FILESDIR}/${PN}-2.30.1-optional-avahi.patch"

	intltoolize --force --copy --automake || die
	eautoreconf
}

multilib-native_src_install_internal() {
	gnome2_src_install
	find "${ED}" -name "*.la" -delete || die "remove of la files failed"
}

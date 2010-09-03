# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/gnome-disk-utility/gnome-disk-utility-2.28.1.ebuild,v 1.10 2010/08/29 17:23:34 armin76 Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2 eutils multilib-native

DESCRIPTION="Disk Utility for GNOME using devicekit-disks"
HOMEPAGE="http://git.gnome.org/cgit/gnome-disk-utility/"
SRC_URI="http://hal.freedesktop.org/releases/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ~ppc ~ppc64 sh sparc x86"
IUSE="doc +nautilus"

RDEPEND="
	>=dev-libs/glib-2.16[lib32?]
	>=dev-libs/dbus-glib-0.71[lib32?]
	>=dev-libs/libunique-1.0[lib32?]
	>=x11-libs/gtk+-2.17[lib32?]
	>=sys-apps/devicekit-disks-007
	>=dev-libs/libatasmart-0.14[lib32?]
	>=gnome-base/gnome-keyring-2.22[lib32?]
	>=x11-libs/libnotify-0.3[lib32?]

	nautilus? ( >=gnome-base/nautilus-2.24[lib32?] )"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	app-text/scrollkeeper
	app-text/gnome-doc-utils[lib32?]
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.35
	doc? ( >=dev-util/gtk-doc-1.3 )"
DOCS="AUTHORS NEWS README TODO"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-static
		$(use_enable nautilus)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Drop encoding from POTFILES.skip, see bug #313351
	epatch "${FILESDIR}/${PN}-2.28.1-fix-potfiles_skip.patch"
}

multilib-native_src_install_internal() {
	gnome2_src_install
	find "${D}" -name "*.la" -delete || die "remove of la files failed"
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnome-keyring/libgnome-keyring-2.30.1.ebuild,v 1.1 2010/06/13 18:29:41 pacho Exp $

EAPI=2

inherit eutils gnome2 multilib-native

DESCRIPTION="Compatibility library for accessing secrets"
HOMEPAGE="http://live.gnome.org/GnomeKeyring"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~arm"
IUSE="debug doc test"

RDEPEND=">=sys-apps/dbus-1.0[lib32?]
	>=dev-libs/eggdbus-0.4[lib32?]
	gnome-base/gconf[lib32?]
	>=gnome-base/gnome-keyring-2.29[lib32?]
	!<gnome-base/gnome-keyring-2.29[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9[lib32?]
	doc? ( >=dev-util/gtk-doc-1.9 )"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		$(use_enable debug)
		$(use_enable test tests)"
}

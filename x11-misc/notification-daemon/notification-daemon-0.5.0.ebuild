# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/notification-daemon/notification-daemon-0.5.0.ebuild,v 1.2 2011/02/05 10:48:18 ssuominen Exp $

EAPI=3
GCONF_DEBUG=no
inherit eutils gnome2 multilib-native

DESCRIPTION="Notification daemon"
HOMEPAGE="http://www.galago-project.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/glib-2.4:2[lib32?]
	>=x11-libs/gtk+-2.18:2[lib32?]
	>=gnome-base/gconf-2.4[lib32?]
	>=dev-libs/dbus-glib-0.78[lib32?]
	>=sys-apps/dbus-1[lib32?]
	>=media-libs/libcanberra-0.4[gtk,lib32?]
	x11-libs/libnotify[lib32?]
	x11-libs/libwnck[lib32?]
	x11-libs/libX11[lib32?]
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.14[lib32?]
	!xfce-extra/xfce4-notifyd"

multilib-native_pkg_setup_internal() {
	DOCS="AUTHORS ChangeLog NEWS"
	G2CONF="${G2CONF} --disable-static"
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-libnotify-0.7.patch
	gnome2_src_prepare
}

multilib-native_src_install_internal() {
	gnome2_src_install
	find "${ED}" -name "*.la" -delete
}

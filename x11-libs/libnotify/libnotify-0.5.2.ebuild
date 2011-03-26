# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libnotify/libnotify-0.5.2.ebuild,v 1.3 2011/03/16 11:04:33 hwoarang Exp $

EAPI="3"

inherit gnome.org multilib-native

DESCRIPTION="Notifications library"
HOMEPAGE="http://www.galago-project.org/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.6:2[lib32?]
	>=dev-libs/glib-2.6:2[lib32?]
	>=dev-libs/dbus-glib-0.76[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"
PDEPEND="|| (
	x11-misc/notification-daemon
	xfce-extra/xfce4-notifyd
	x11-misc/notify-osd
	>=x11-wm/awesome-3.4.4
	kde-base/knotify
)"

multilib-native_src_configure_internal() {
	econf \
		--disable-static \
		--disable-dependency-tracking
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS || die "dodoc failed"
}

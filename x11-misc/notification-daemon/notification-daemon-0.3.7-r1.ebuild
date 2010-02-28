# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/notification-daemon/notification-daemon-0.3.7-r1.ebuild,v 1.1 2008/11/20 14:48:07 cardoe Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

DESCRIPTION="Notifications daemon"
HOMEPAGE="http://www.galago-project.org/"
SRC_URI="http://www.galago-project.org/files/releases/source/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=dev-libs/glib-2.4.0[lib32?]
		 >=x11-libs/gtk+-2.4.0[lib32?]
		 >=gnome-base/gconf-2.4.0[lib32?]
		 >=x11-libs/libsexy-0.1.3[lib32?]
		 >=dev-libs/dbus-glib-0.71[lib32?]
		 x11-libs/libwnck[lib32?]"
DEPEND="${RDEPEND}
		=sys-devel/automake-1.9*
		>=sys-devel/gettext-0.14[lib32?]
		!xfce-extra/notification-daemon-xfce"

DOCS="AUTHORS ChangeLog NEWS"

multilib-native_src_prepare_internal() {
	# fix line wrapping, upstream bug #162
	epatch "${FILESDIR}"/${PN}-0.3.7-line-wrapping.patch
}

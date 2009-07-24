# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libbonobo/libbonobo-2.24.1.ebuild,v 1.3 2009/04/19 15:43:06 maekke Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="GNOME CORBA framework"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2.1 GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ppc ppc64 ~sh ~sparc x86 ~x86-fbsd"
IUSE="debug doc"

RDEPEND=">=dev-libs/glib-2.14[lib32?]
	>=gnome-base/orbit-2.14.0[lib32?]
	>=dev-libs/libxml2-2.4.20[lib32?]
	>=sys-apps/dbus-1.0.0[lib32?]
	>=dev-libs/dbus-glib-0.74[lib32?]
	>=dev-libs/popt-1.5[lib32?]
	!gnome-base/bonobo-activation"
DEPEND="${RDEPEND}
	sys-devel/flex
	x11-apps/xrdb
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.35
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF} $(use_enable debug bonobo-activation-debug)"
}

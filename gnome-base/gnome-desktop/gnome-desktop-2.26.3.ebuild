# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-desktop/gnome-desktop-2.26.3.ebuild,v 1.1 2009/07/11 08:57:17 eva Exp $

EAPI="2"

inherit eutils gnome2 multilib-native

DESCRIPTION="Libraries for the gnome desktop that are not part of the UI"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 FDL-1.1 LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=x11-libs/gtk+-2.14.0[lib32?]
	>=dev-libs/glib-2.19.1[lib32?]
	>=x11-libs/libXrandr-1.2[lib32?]
	>=gnome-base/gconf-2[lib32?]
	>=x11-libs/startup-notification-0.5[lib32?]"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9[lib32?]
	>=app-text/gnome-doc-utils-0.3.2
	doc? ( >=dev-util/gtk-doc-1.4 )
	~app-text/docbook-xml-dtd-4.1.2
	x11-proto/xproto
	>=x11-proto/randrproto-1.2"
PDEPEND=">=dev-python/pygtk-2.8
	>=dev-python/pygobject-2.14
	>=dev-python/libgnome-python-2.22"

# Includes X11/Xatom.h in libgnome-desktop/gnome-bg.c which comes from xproto
# Includes X11/extensions/Xrandr.h that includes randr.h from randrproto (and
# eventually libXrandr shouldn't RDEPEND on randrproto)

DOCS="AUTHORS ChangeLog HACKING NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		--with-gnome-distributor=Gentoo
		--disable-scrollkeeper
		--disable-static"
}

pkg_preinst() {
	gnome2_pkg_preinst
	preserve_old_lib /usr/$(get_libdir)/libgnome-desktop-2.so.7
	preserve_old_lib /usr/$(get_libdir)/libgnome-desktop-2.so.7.2.6
}

pkg_postinst() {
	gnome2_pkg_postinst
	preserve_old_lib_notify /usr/$(get_libdir)/libgnome-desktop-2.so.7
	preserve_old_lib_notify /usr/$(get_libdir)/libgnome-desktop-2.so.7.2.6
	ewarn
	ewarn "If you are upgrading from <gnome-base/gnome-desktop-2.25, please"
	ewarn "make sure you run revdep-rebuild at the end of the upgrade."
}

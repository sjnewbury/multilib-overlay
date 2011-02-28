# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgdata/libgdata-0.8.0.ebuild,v 1.4 2011/02/24 18:41:41 tomka Exp $

EAPI="3"
GCONF_DEBUG="yes"

inherit eutils gnome2 multilib-native

DESCRIPTION="GLib-based library for accessing online service APIs using the GData protocol"
HOMEPAGE="http://live.gnome.org/libgdata"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc x86"
IUSE="doc gnome +introspection"

# gtk+ is needed for gdk
RDEPEND=">=dev-libs/glib-2.19:2[lib32?]
	|| (
		>=x11-libs/gdk-pixbuf-2.14:2[lib32?]
		>=x11-libs/gtk+-2.14:2[lib32?] )
	>=dev-libs/libxml2-2[lib32?]
	>=net-libs/libsoup-2.26.1:2.4[introspection?,lib32?]
	gnome? ( >=net-libs/libsoup-gnome-2.26.1:2.4[introspection?,lib32?] )
	introspection? ( >=dev-libs/gobject-introspection-0.9.7 )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	doc? ( >=dev-util/gtk-doc-1.14 )"

multilib-native_pkg_setup_internal() {
	DOCS="AUTHORS ChangeLog HACKING NEWS README"
	G2CONF="${G2CONF}
		--disable-static
		$(use_enable gnome)
		$(use_enable introspection)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Disable tests requiring network access, bug #307725
	sed -e '/^TEST_PROGS = / s:\(.*\):TEST_PROGS = general perf\nOLD_\1:' \
		-i gdata/tests/Makefile.in || die "network test disable failed"
}

src_test() {
	unset ORBIT_SOCKETDIR
	unset DBUS_SESSION_BUS_ADDRESS
	dbus-launch emake check || die "emake check failed"
}

multilib-native_pkg_preinst_internal() {
	gnome2_pkg_preinst
	preserve_old_lib /usr/$(get_libdir)/libgdata.so.7
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst
	preserve_old_lib_notify /usr/$(get_libdir)/libgdata.so.7
}

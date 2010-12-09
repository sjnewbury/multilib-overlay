# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgdata/libgdata-0.6.4.ebuild,v 1.12 2010/10/24 13:29:13 pacho Exp $

EAPI="2"

inherit eutils gnome2 multilib-native

DESCRIPTION="GLib-based library for accessing online service APIs using the GData protocol"
HOMEPAGE="http://live.gnome.org/libgdata"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sparc x86"
IUSE="doc gnome" # introspection

# gtk+ is needed for gdk
RDEPEND=">=dev-libs/glib-2.19[lib32?]
	>=x11-libs/gtk+-2[lib32?]
	>=dev-libs/libxml2-2[lib32?]
	>=net-libs/libsoup-2.26.1:2.4[lib32?]
	gnome? ( >=net-libs/libsoup-gnome-2.26.1:2.4[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-static
		--disable-introspection
		$(use_enable gnome)"
}

multilib-native_src_prepare_internal() {
	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in \
		|| die "sed failed"

	# Disable broken tests, update upstream bug #604313
	sed -e 's:^\(.*"/media/thumbnail".*\):/*\1*/:' \
		-e 's:^\(.*"/service/network_error".*\):/*\1*/:' \
		-i gdata/tests/general.c || die
	sed 's:^\(.*"/contacts/insert/simple".*\):/*\1*/:' \
		-i gdata/tests/contacts.c || die
	sed -e 's:^\(.*"/documents/upload/only_file_get_entry".*\):/*\1*/:' \
		-e 's:^\(.*"/documents/update/only_metadata".*\):/*\1*/:' \
		-i gdata/tests/documents.c || die
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	emake check || die "emake check failed"
}

multilib-native_pkg_preinst_internal() {
	gnome2_pkg_preinst
	preserve_old_lib /usr/$(get_libdir)/libgdata.so.6
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst
	preserve_old_lib_notify /usr/$(get_libdir)/libgdata.so.6
}

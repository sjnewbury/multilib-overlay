# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/gtkhtml/gtkhtml-3.32.2.ebuild,v 1.6 2011/03/22 19:28:58 ranger Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit gnome2 eutils multilib-native

DESCRIPTION="Lightweight HTML Rendering/Printing/Editing Engine"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="3.14"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.20:2[lib32?]
	>=x11-themes/gnome-icon-theme-2.22.0
	>=gnome-base/orbit-2[lib32?]
	>=app-text/enchant-1.1.7[lib32?]
	gnome-base/gconf:2[lib32?]
	>=app-text/iso-codes-0.49
	>=net-libs/libsoup-2.26.0:2.4[lib32?]"
DEPEND="${RDEPEND}
	x11-proto/xproto
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.40.0
	>=dev-util/pkgconfig-0.9[lib32?]"

multilib-native_pkg_setup_internal() {
	ELTCONF="--reverse-deps"
	G2CONF="${G2CONF}
		--disable-static
		--disable-deprecated-warning-flags"
	DOCS="AUTHORS BUGS ChangeLog NEWS README TODO"
}

multilib-native_pkg_preinst_internal() {
	gnome2_pkg_preinst
	preserve_old_lib /usr/$(get_libdir)/libgtkhtml-editor.so.0
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst
	preserve_old_lib_notify /usr/$(get_libdir)/libgtkhtml-editor.so.0
}

multilib-native_src_install_internal() {
	gnome2_src_install
	# Remove .la files since old will be removed anyway while updating
	find "${ED}" -name "*.la" -delete || die "remove of la files failed"
}

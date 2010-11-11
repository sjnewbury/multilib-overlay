# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libsoup/libsoup-2.24.3.ebuild,v 1.13 2010/10/29 20:05:13 eva Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="An HTTP library implementation in C"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="2.4"
KEYWORDS="~mips"
# Do NOT build with --disable-debug/--enable-debug=no - gnome2.eclass takes care of that
IUSE="debug doc ssl"

RDEPEND=">=dev-libs/glib-2.15.3[lib32?]
		 >=dev-libs/libxml2-2[lib32?]
		 ssl? ( >=net-libs/gnutls-1[lib32?] )"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.9[lib32?]
		doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF} $(use_enable ssl) --disable-static"
}

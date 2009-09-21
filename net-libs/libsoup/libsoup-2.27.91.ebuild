# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libsoup/libsoup-2.26.2.ebuild,v 1.3 2009/05/21 18:14:56 nirbheek Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="An HTTP library implementation in C"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="2.4"
KEYWORDS=""
# Do NOT build with --disable-debug/--enable-debug=no - gnome2.eclass takes care of that
IUSE="debug doc gnome ssl"

RDEPEND=">=dev-libs/glib-2.15.3[lib32?]
	>=dev-libs/libxml2-2[lib32?]
	gnome? (
		net-libs/libproxy[lib32?]
		>=gnome-base/gconf-2[lib32?]
		dev-db/sqlite:3[lib32?] )
	ssl? ( >=net-libs/gnutls-1[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"
#	test? (
#		www-servers/apache
#		dev-lang/php
#		net-misc/curl )

DOCS="AUTHORS NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-static
		$(use_with gnome)
		$(use_enable ssl)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix test to follow POSIX (for x86-fbsd)
	# No patch to prevent having to eautoreconf
	sed -e 's/\(test.*\)==/\1=/g' -i configure.in configure || die "sed failed"
}

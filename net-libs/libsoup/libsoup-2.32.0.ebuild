# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libsoup/libsoup-2.32.0.ebuild,v 1.2 2010/10/24 13:43:42 pacho Exp $

EAPI="3"
GCONF_DEBUG="yes"

inherit autotools eutils gnome2 multilib-native

DESCRIPTION="An HTTP library implementation in C"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="2.4"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="debug doc +introspection ssl test"

RDEPEND=">=dev-libs/glib-2.21.3[lib32?]
	>=dev-libs/libxml2-2[lib32?]
	introspection? ( >=dev-libs/gobject-introspection-0.9.5 )
	ssl? ( >=net-libs/gnutls-2.1.7[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/gtk-doc-am-1.10
	doc? ( >=dev-util/gtk-doc-1.10 )"
#	test? (
#		www-servers/apache
#		dev-lang/php
#		net-misc/curl )

DOCS="AUTHORS NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-static
		--without-gnome
		$(use_enable introspection)
		$(use_enable ssl)"
}

multilib-native_src_configure_internal() {
	# FIXME: we need addpredict to workaround bug #324779 until
	# root cause (bug #249496) is solved
	addpredict /usr/share/snmp/mibs/.index
	gnome2_src_configure
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	if ! use test; then
		# don't waste time building tests (bug #226271)
		sed 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed failed"
	fi

	# Patch *must* be applied conditionally (see patch for details)
	if use doc; then
		# Fix bug 268592 (build fails without gnome && doc)
		epatch "${FILESDIR}/${PN}-2.30.1-fix-build-without-gnome-with-doc.patch"
		eautoreconf
	fi
}

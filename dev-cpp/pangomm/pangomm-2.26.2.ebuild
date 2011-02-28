# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/pangomm/pangomm-2.26.2.ebuild,v 1.8 2011/02/21 10:01:07 eva Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2 multilib-native

DESCRIPTION="C++ interface for pango"
HOMEPAGE="http://www.gtkmm.org"

LICENSE="LGPL-2.1"
SLOT="2.4"
KEYWORDS="ppc ppc64"
IUSE="doc"

RDEPEND=">=x11-libs/pango-1.23.0[lib32?]
	>=dev-cpp/glibmm-2.14.1[lib32?]
	>=dev-cpp/cairomm-1.2.2[lib32?]
	dev-libs/libsigc++:2[lib32?]
	!<dev-cpp/gtkmm-2.13:2.4"

DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	doc? (
		media-gfx/graphviz[lib32?]
		dev-libs/libxslt[lib32?]
		app-doc/doxygen )"

DOCS="AUTHORS ChangeLog NEWS README*"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-maintainer-mode
		$(use_enable doc documentation)"
}

# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/pangomm/pangomm-2.26.3.ebuild,v 1.7 2011/03/22 20:00:54 ranger Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit gnome2 multilib-native

DESCRIPTION="C++ interface for pango"
HOMEPAGE="http://www.gtkmm.org"

LICENSE="LGPL-2.1"
SLOT="2.4"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
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

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-maintainer-mode
		$(use_enable doc documentation)"
	DOCS="AUTHORS ChangeLog NEWS README*"
}

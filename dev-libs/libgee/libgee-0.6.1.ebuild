# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgee/libgee-0.6.1.ebuild,v 1.5 2011/02/24 18:42:04 tomka Exp $

EAPI="3"

inherit gnome2 multilib multilib-native

DESCRIPTION="GObject-based interfaces and classes for commonly used data structures."
HOMEPAGE="http://live.gnome.org/Libgee"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc x86"
IUSE="+introspection"

RDEPEND=">=dev-libs/glib-2.12[lib32?]
	introspection? ( >=dev-libs/gobject-introspection-0.9.6 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

multilib-native_pkg_setup_internal() {
	DOCS="AUTHORS ChangeLog* MAINTAINERS NEWS README"
	G2CONF="${G2CONF} $(use_enable introspection)"
}

multilib-native_src_install_internal() {
	gnome2_src_install
	find "${D}" -name "*.la" -delete || die
}

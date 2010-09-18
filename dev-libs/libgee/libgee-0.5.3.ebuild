# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgee/libgee-0.5.3.ebuild,v 1.1 2010/09/16 20:34:32 eva Exp $

EAPI="2"

inherit gnome2 multilib multilib-native

DESCRIPTION="GObject-based interfaces and classes for commonly used data structures."
HOMEPAGE="http://live.gnome.org/Libgee"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="introspection"

RDEPEND=">=dev-libs/glib-2.12[lib32?]
	introspection? ( >=dev-libs/gobject-introspection-0.9[lib32?] )"
DEPEND="${RDEPEND}
	dev-lang/vala[lib32?]
	dev-util/pkgconfig[lib32?]"

DOCS="AUTHORS ChangeLog* MAINTAINERS NEWS README"

multilib-native_src_install_internal() {
	gnome2_src_install
	find "${D}" -name "*.la" -delete || die
}

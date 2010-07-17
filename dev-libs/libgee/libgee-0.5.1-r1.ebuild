# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgee/libgee-0.5.1-r1.ebuild,v 1.2 2010/07/16 18:52:18 mr_bones_ Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="GObject-based interfaces and classes for commonly used data structures."
HOMEPAGE="http://live.gnome.org/Libgee"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND=">=dev-libs/glib-2.12[lib32?]"
DEPEND="${RDEPEND}
	dev-lang/vala[lib32?]
	dev-util/pkgconfig[lib32?]"

multilib-native_src_install_internal() {
	DOCS="AUTHORS ChangeLog* MAINTAINERS NEWS README"
	gnome2_src_install
	rm "${D}"/usr/lib*/*.la
}

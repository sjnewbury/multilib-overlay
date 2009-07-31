# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/pangomm/pangomm-2.14.1.ebuild,v 1.2 2008/12/31 06:27:06 mr_bones_ Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="C++ interface for pango"
HOMEPAGE="http://www.gtkmm.org"

LICENSE="LGPL-2.1"
SLOT="2.4"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=x11-libs/pango-1.21.4[lib32?]
	>=dev-cpp/glibmm-2.14.1[lib32?]
	>=dev-cpp/cairomm-1.2.2[lib32?]
	!<dev-cpp/gtkmm-2.13:2.4[lib32?]"

DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

DOCS="AUTHORS CHANGES ChangeLog PORTING NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable doc docs)"
}

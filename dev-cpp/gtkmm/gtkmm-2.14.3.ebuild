# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/gtkmm/gtkmm-2.14.3.ebuild,v 1.3 2009/03/24 10:11:09 remi Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="C++ interface for GTK+2"
HOMEPAGE="http://www.gtkmm.org"

LICENSE="LGPL-2.1"
SLOT="2.4"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc examples test"

RDEPEND=">=dev-cpp/glibmm-2.18[$(get_ml_usedeps)]
	>=x11-libs/gtk+-2.14.0[$(get_ml_usedeps)]
	>=dev-cpp/cairomm-1.2.2[$(get_ml_usedeps)]
	>=dev-cpp/pangomm-2.14.0[$(get_ml_usedeps)]
	>=dev-libs/atk-1.9.1[$(get_ml_usedeps)]"

DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)]"

DOCS="AUTHORS CHANGES ChangeLog PORTING NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		--enable-api-atkmm
		$(use_enable doc docs)
		$(use_enable examples demos)"
}

src_unpack() {
	gnome2_src_unpack

	if ! use test; then
		# don't waste time building tests
		sed -i 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' Makefile.in || die "sed failed"
	fi
}

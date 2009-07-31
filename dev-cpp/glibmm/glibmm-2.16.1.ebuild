# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/glibmm/glibmm-2.16.1.ebuild,v 1.10 2009/05/10 22:15:53 eva Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="C++ interface for glib2"
HOMEPAGE="http://www.gtkmm.org"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="ppc64"
IUSE="doc examples"

RDEPEND=">=dev-libs/libsigc++-2.2[$(get_ml_usedeps)]
		 >=dev-libs/glib-2.16[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
		dev-util/pkgconfig[$(get_ml_usedeps)]
		doc? ( app-doc/doxygen )"

DOCS="AUTHORS ChangeLog NEWS README"

src_unpack() {
	gnome2_src_unpack

	if ! use examples; then
		# don't waste time building the examples
		sed -i 's/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/' Makefile.in || die "sed failed"
	fi
}

ml-native_src_install() {
	gnome2_src_install

	if ! use doc && ! use examples; then
		rm -fr "${D}/usr/share/doc/glibmm-2.4"
	fi

	if use examples; then
		find examples -type d -name '.deps' -exec rm -rf {} \; 2>/dev/null
		dodoc examples
	fi
}

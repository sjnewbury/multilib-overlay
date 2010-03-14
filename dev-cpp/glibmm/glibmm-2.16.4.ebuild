# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/glibmm/glibmm-2.16.4.ebuild,v 1.8 2009/01/07 17:56:58 armin76 Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="C++ interface for glib2"
HOMEPAGE="http://www.gtkmm.org"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ~ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc examples"

RDEPEND=">=dev-libs/libsigc++-2.2[lib32?]
		 >=dev-libs/glib-2.16[lib32?]"
DEPEND="${RDEPEND}
		dev-util/pkgconfig[lib32?]
		doc? ( app-doc/doxygen )"

DOCS="AUTHORS ChangeLog NEWS README"

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# don't waste time building tests
	# no USE=test because there is no "check" target
	sed -i 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' Makefile.in || die "sed failed"

	if ! use examples; then
		# don't waste time building examples
		sed -i 's/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/' Makefile.in || die "sed failed"
	fi
}

multilib-native_src_install_internal() {
	gnome2_src_install

	if ! use doc && ! use examples; then
		rm -fr "${D}/usr/share/doc/glibmm-2.4"
	fi

	if use examples; then
		find examples -type d -name '.deps' -exec rm -rf {} \; 2>/dev/null
		dodoc examples
	fi
}

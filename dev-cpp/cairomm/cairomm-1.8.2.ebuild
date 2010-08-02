# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/cairomm/cairomm-1.8.2.ebuild,v 1.4 2010/08/01 10:56:11 fauli Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="C++ bindings for the Cairo vector graphics library"
HOMEPAGE="http://cairographics.org/cairomm"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc svg"

# FIXME: svg support is automagic
RDEPEND=">=x11-libs/cairo-1.8[svg?,lib32?]
	dev-libs/libsigc++:2[lib32?]"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

multilib-native_src_prepare_internal() {
	# don't waste time building examples because they are marked as "noinst"
	sed -i 's/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/' Makefile.in || die "sed failed"

	# don't waste time building tests
	# they require the boost Unit Testing framework, that's not in base boost
	sed -i 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' Makefile.in || die "sed failed"
}

multilib-native_src_configure_internal() {
	econf $(use_enable doc docs)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README ChangeLog || die "dodoc failed"
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/cairomm/cairomm-1.6.0.ebuild,v 1.10 2009/04/10 14:00:16 armin76 Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="C++ bindings for the Cairo vector graphics library"
HOMEPAGE="http://cairographics.org/cairomm"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ~ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=x11-libs/cairo-1.5.14[lib32?]"
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
	econf $(use_enable doc docs) || die "econf failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README ChangeLog
}

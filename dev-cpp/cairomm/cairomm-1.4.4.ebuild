# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/cairomm/cairomm-1.4.4.ebuild,v 1.10 2009/10/12 20:08:39 eva Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="C++ bindings for the Cairo vector graphics library"
HOMEPAGE="http://cairographics.org/cairomm"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc examples"

RDEPEND=">=x11-libs/cairo-1.4.0[lib32?]"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

multilib-native_src_prepare_internal() {
	if ! use examples; then
		# don't waste time building the examples
		sed -i 's/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/' Makefile.in || \
			die "sed Makefile.in failed"
	fi
}

multilib-native_src_configure_internal() {
	econf $(use_enable doc docs) || die "econf failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	if use examples; then
		cp -R examples "${D}"/usr/share/doc/${PF}
	fi
}

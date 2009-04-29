# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycairo/pycairo-1.2.2.ebuild,v 1.14 2008/05/29 16:24:40 hawking Exp $

EAPI=2
NEED_PYTHON=2.3
WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit eutils autotools python multilib multilib-native

DESCRIPTION="Python wrapper for cairo vector graphics library"
HOMEPAGE="http://cairographics.org/pycairo/"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="examples numeric"

RDEPEND=">=x11-libs/cairo-1.2.0[lib32?]
	numeric? ( dev-python/numeric[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

multilib-native_src_prepare_internal() {
	# don't run py-compile
	sed -i \
		-e '/if test -n "$$dlist"; then/,/else :; fi/d' \
		cairo/Makefile.in || die "sed in cairo/Makefile.in failed"

	epatch "${FILESDIR}"/${P}-no-automagic-deps.patch

	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		$(use_with numeric) \
		|| die "econf failed"
}

multilib-native_src_install_internal() {
	einstall || die "install failed"

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
		rm "${D}"/usr/share/doc/${PF}/examples/Makefile*
	fi

	dodoc AUTHORS NOTES README NEWS ChangeLog
}

multilib-native_pkg_postinst_internal() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/cairo
}

multilib-native_pkg_postrm_internal() {
	python_mod_cleanup
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycairo/pycairo-1.8.4.ebuild,v 1.1 2009/04/25 16:25:19 arfrever Exp $

EAPI=2
NEED_PYTHON=2.6

inherit distutils multilib-native

DESCRIPTION="Python wrapper for cairo vector graphics library"
HOMEPAGE="http://cairographics.org/pycairo/"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="examples"

RDEPEND=">=x11-libs/cairo-1.8.4[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

PYTHON_MODNAME="cairo"
DOCS="AUTHORS NEWS doc/*"

ml-native_src_prepare() {
	# don't run py-compile
	sed -i \
		-e '/if test -n "$$dlist"; then/,/else :; fi/d' \
		cairo/Makefile.in || die "sed in cairo/Makefile.in failed"
}

ml-native_src_install() {
	distutils_src_install

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
		rm "${D}"/usr/share/doc/${PF}/examples/Makefile*
	fi
}

src_test() {
	cd test
	PYTHONPATH="$(ls -d ${S}/build/lib.*)" "${python}" test.py || die "tests failed"
}

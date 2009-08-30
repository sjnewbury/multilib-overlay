# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycairo/pycairo-1.8.8.ebuild,v 1.1 2009/08/29 01:13:12 arfrever Exp $

EAPI=2
NEED_PYTHON="2.6"
SUPPORT_PYTHON_ABIS="1"

inherit distutils multilib-native

DESCRIPTION="Python wrapper for cairo vector graphics library"
HOMEPAGE="http://cairographics.org/pycairo/"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="examples"

RDEPEND=">=x11-libs/cairo-1.8.8[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

PYTHON_MODNAME="cairo"
DOCS="AUTHORS NEWS doc/*"

multilib-native_src_prepare_internal() {
	# don't run py-compile.
	sed -i \
		-e '/if test -n "$$dlist"; then/,/else :; fi/d' \
		src/Makefile.in || die "sed in src/Makefile.in failed"
}

multilib-native_src_install_internal() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
		rm "${D}"/usr/share/doc/${PF}/examples/Makefile*
	fi

	# dev-python/pycairo-1.8.8 doesn't install __init__.py automatically.
	# http://lists.cairographics.org/archives/cairo/2009-August/018044.html
	installation() {
		insinto "$(python_get_sitedir)/cairo"
		doins src/__init__.py
	}
	python_execute_function -q installation
}

src_test() {
	cd test
	PYTHONPATH="$(ls -d ${S}/build/lib.*)" "${python}" test.py || die "tests failed"
}

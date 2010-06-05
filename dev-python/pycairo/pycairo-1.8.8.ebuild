# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycairo/pycairo-1.8.8.ebuild,v 1.16 2010/02/07 20:55:36 pva Exp $

EAPI="2"

NEED_PYTHON="2.6"
SUPPORT_PYTHON_ABIS="1"

inherit eutils distutils multilib multilib-native

DESCRIPTION="Python wrapper for cairo vector graphics library"
HOMEPAGE="http://cairographics.org/pycairo/ http://pypi.python.org/pypi/pycairo"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc examples svg"

RDEPEND=">=x11-libs/cairo-1.8.8[svg?,lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	doc? ( >=dev-python/sphinx-0.6 )"
RESTRICT_PYTHON_ABIS="2.4 2.5 3.*"

PYTHON_MODNAME="cairo"
DOCS="AUTHORS NEWS README"

multilib-native_src_prepare_internal() {
	# Don't run py-compile.
	sed -i \
		-e '/if test -n "$$dlist"; then/,/else :; fi/d' \
		src/Makefile.in || die "sed in src/Makefile.in failed"

	epatch "${FILESDIR}/${P}-pkgconfig_dir.patch"
	epatch "${FILESDIR}/${P}-svg_check.patch"
}

multilib-native_src_configure_internal() {
	if use doc; then
		econf
	fi

	if ! use svg; then
		export PYCAIRO_DISABLE_SVG="1"
	fi
}

multilib-native_src_compile_internal() {
	distutils_src_compile

	if use doc; then
		emake html || die "emake html failed"
	fi
}

src_test() {
	testing() {
		cp src/__init__.py $(ls -d build-${PYTHON_ABI}/lib.*)/cairo
		pushd test > /dev/null
		# examples_test.test_snippets_png() calls os.chdir().
		PYTHONPATH="$(ls -d ../build-${PYTHON_ABI}/lib.*):../$(ls -d ../build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" -c "import examples_test; examples_test.test_examples(); examples_test.test_snippets_png()" || return 1
		popd > /dev/null
	}
	python_execute_function testing
}

multilib-native_src_install_internal() {
	[[ -z "${ED}" ]] && local ED="${D}"
	PKGCONFIG_DIR="${EPREFIX}/usr/$(get_libdir)/pkgconfig" distutils_src_install

	if use doc; then
		dohtml -r doc/.build/html/ || die "dohtml -r doc/.build/html/ failed"
	fi

	if use examples; then
		# Delete files created by tests.
		find examples{,/cairo_snippets/snippets} -maxdepth 1 -name "*.png" | xargs rm -f

		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
		rm "${ED}"/usr/share/doc/${PF}/examples/Makefile*
	fi

	# dev-python/pycairo-1.8.8 doesn't install __init__.py automatically.
	# http://lists.cairographics.org/archives/cairo/2009-August/018044.html
	installation() {
		insinto "$(python_get_sitedir)/cairo"
		doins src/__init__.py
	}
	python_execute_function -q installation
}

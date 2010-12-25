# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/numpy/numpy-1.3.0-r2.ebuild,v 1.5 2010/12/19 16:41:54 arfrever Exp $

EAPI="2"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* *-jython"

inherit distutils eutils flag-o-matic toolchain-funcs versionator multilib-native

NP="${PN}-$(get_version_component_range 1-2)"

DESCRIPTION="Fast array and numerical python library"
HOMEPAGE="http://numpy.scipy.org/ http://pypi.python.org/pypi/numpy"
SRC_URI="mirror://sourceforge/numpy/${P}.tar.gz
	doc? (
		http://docs.scipy.org/doc/${NP}.x/numpy-html.zip -> ${NP}-html.zip
		http://docs.scipy.org/doc/${NP}.x/numpy-ref.pdf -> ${NP}-ref.pdf
		http://docs.scipy.org/doc/${NP}.x/numpy-user.pdf -> ${NP}-user.pdf
	)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc lapack test"

RDEPEND="dev-python/setuptools[lib32?]
	lapack? ( virtual/cblas virtual/lapack )"
DEPEND="${RDEPEND}
	lapack? ( dev-util/pkgconfig[lib32?] )
	test? ( >=dev-python/nose-0.10 )
	doc? ( app-arch/unzip )"

multilib-native_pkg_setup_internal() {
	# See progress in http://projects.scipy.org/scipy/numpy/ticket/573
	# with the subtle difference that we don't want to break Darwin where
	# -shared is not a valid linker argument
	if [[ ${CHOST} != *-darwin* ]] ; then
		append-ldflags -shared
	fi

	# only one fortran to link with:
	# linking with cblas and lapack library will force
	# autodetecting and linking to all available fortran compilers
	use lapack || return
	[[ -z ${FC} ]] && FC=$(tc-getFC)
	# when fortran flags are set, pic is removed.
	FFLAGS="${FFLAGS} -fPIC"
	export NUMPY_FCONFIG="config_fc --noopt --noarch"
}

multilib-native_src_unpack_internal() {
	unpack ${P}.tar.gz
	if use doc; then
		unzip -qo "${DISTDIR}"/${NP}-html.zip -d html || die
	fi
}

multilib-native_src_prepare_internal() {
	# Fix some paths and docs in f2py
	epatch "${FILESDIR}"/${PN}-1.1.0-f2py.patch

	epatch "${FILESDIR}/${P}-parisc.patch" # bug 277438
	epatch "${FILESDIR}/${P}-alpha.patch" # bug 277438
	epatch "${FILESDIR}/${P}-arm-sh.patch"

	epatch "${FILESDIR}"/${P}-fenv-freebsd.patch # bug 279487
	epatch "${FILESDIR}"/${P}-darwin-no-arch.patch

	# Gentoo patch for ATLAS library names
	sed -i \
		-e "s:'f77blas':'blas':g" \
		-e "s:'ptf77blas':'blas':g" \
		-e "s:'ptcblas':'cblas':g" \
		-e "s:'lapack_atlas':'lapack':g" \
		numpy/distutils/system_info.py \
		|| die "sed system_info.py failed"

	if use lapack; then
		append-ldflags "$(pkg-config --libs-only-other cblas lapack)"
		sed -i -e '/NO_ATLAS_INFO/,+1d' numpy/core/setup.py || die
		cat >> site.cfg <<-EOF
			[atlas]
			include_dirs = $(pkg-config --cflags-only-I \
				cblas | sed -e 's/^-I//' -e 's/ -I/:/g')
			library_dirs = $(pkg-config --libs-only-L \
				cblas blas lapack | sed -e \
				's/^-L//' -e 's/ -L/:/g' -e 's/ //g'):"${EPREFIX}"/usr/$(get_libdir)
			atlas_libs = $(pkg-config --libs-only-l \
				cblas blas | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
			lapack_libs = $(pkg-config --libs-only-l \
				lapack | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
			[blas_opt]
			include_dirs = $(pkg-config --cflags-only-I \
				cblas | sed -e 's/^-I//' -e 's/ -I/:/g')
			library_dirs = $(pkg-config --libs-only-L \
				cblas blas | sed -e 's/^-L//' -e 's/ -L/:/g' \
				-e 's/ //g'):"${EPREFIX}"/usr/$(get_libdir)
			libraries = $(pkg-config --libs-only-l \
				cblas blas | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
			[lapack_opt]
			library_dirs = $(pkg-config --libs-only-L \
				lapack | sed -e 's/^-L//' -e 's/ -L/:/g' \
				-e 's/ //g'):"${EPREFIX}"/usr/$(get_libdir)
			libraries = $(pkg-config --libs-only-l \
				lapack | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
		EOF
	else
		export {ATLAS,PTATLAS,BLAS,LAPACK,MKL}=None
	fi
}

multilib-native_src_compile_internal() {
	distutils_src_compile ${NUMPY_FCONFIG}
}

src_test() {
	testing() {
		"$(PYTHON)" setup.py ${NUMPY_FCONFIG} build -b "build-${PYTHON_ABI}" install \
			--home="${S}/test-${PYTHON_ABI}" --no-compile || die "install test failed"
		pushd "${S}/test-${PYTHON_ABI}/"lib* > /dev/null
		PYTHONPATH=python "$(PYTHON)" -c "import numpy; numpy.test()" 2>&1 | tee test.log
		grep -q '^ERROR' test.log && die "test failed"
		popd > /dev/null
		rm -fr test-${PYTHON_ABI}
	}
	python_execute_function testing
}

multilib-native_src_install_internal() {
	[[ -z ${ED} ]] && local ED=${D}
	distutils_src_install ${NUMPY_FCONFIG}
	dodoc THANKS.txt DEV_README.txt COMPATIBILITY
	rm -f "${ED}"/usr/lib/python*/site-packages/numpy/*.txt || die
	docinto f2py
	dodoc numpy/f2py/docs/*.txt || die "dodoc f2py failed"
	doman numpy/f2py/f2py.1 || die "doman failed"
	if use doc; then
		insinto /usr/share/doc/${PF}
		doins -r "${WORKDIR}"/html || die
		doins  "${DISTDIR}"/${NP}*pdf || die
	fi
}

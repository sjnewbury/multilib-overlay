# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/numeric/numeric-24.2-r5.ebuild,v 1.2 2007/10/15 14:19:12 bicatali Exp $

NEED_PYTHON=2.3

inherit distutils eutils multilib-native

MY_P=Numeric-${PV}

DESCRIPTION="Numerical multidimensional array language facility for Python."
HOMEPAGE="http://numeric.scipy.org/"
SRC_URI="mirror://sourceforge/numpy/${MY_P}.tar.gz
	doc? ( http://numpy.scipy.org/numpy.pdf )"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~arm ~mips ~sh ~s390"
IUSE="doc"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}

	# fix list problem
	epatch "${FILESDIR}"/${P}-arrayobject.patch
	# fix skips of acosh, asinh
	epatch "${FILESDIR}"/${P}-umath.patch
	# fix eigenvalue hang
	epatch "${FILESDIR}"/${P}-eigen.patch
	# fix a bug in the test
	epatch "${FILESDIR}"/${P}-test.patch
	# fix only for python-2.5
	distutils_python_version
	[[ "${PYVER}" == 2.5 ]] && epatch "${FILESDIR}"/${P}-python25.patch
	# fix for dotblas from uncommited cvs
	epatch "${FILESDIR}"/${P}-dotblas.patch
}

src_test() {
	cd build/lib*
	PYTHONPATH=. "${python}" "${S}"/Test/test.py \
		|| die "test failed"
}

multilib-native_src_install_internal() {
	distutils_src_install

	# install various README from packages
	newdoc Packages/MA/README README.MA || die
	newdoc Packages/RNG/README README.RNG || die

	# install tutorial and docs
	if use doc; then
		insinto /usr/share/doc/${PF}
		doins -r Test Demo/NumTut || die "install tutorial failed"
		newins "${DISTDIR}"/numpy.pdf numeric.pdf || die "install doc failed"
	fi
}

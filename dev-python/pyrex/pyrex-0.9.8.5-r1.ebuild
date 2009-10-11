# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyrex/pyrex-0.9.8.5-r1.ebuild,v 1.3 2009/10/10 09:59:15 maekke Exp $

EAPI="2"
NEED_PYTHON=2.3
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils multilib-native

MY_P="Pyrex-${PV}"
DESCRIPTION="A language for writing Python extension modules"
HOMEPAGE="http://www.cosc.canterbury.ac.nz/~greg/python/Pyrex"
SRC_URI="http://www.cosc.canterbury.ac.nz/~greg/python/Pyrex/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha amd64 arm ~hppa ~ia64 ~mips ppc ~ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd"
IUSE="examples"

S="${WORKDIR}/${MY_P}"

PYTHON_MODNAME="Pyrex"

# This version doesn't work with older setuptools #218815
RDEPEND="!<dev-python/setuptools-0.6_rc8"

RESTRICT_PYTHON_ABIS="3*"

multilib-native_src_install_internal() {
	DOCS="CHANGES.txt ToDo.txt USAGE.txt"
	distutils_src_install

	dohtml -A c -r Doc/*

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r Demos
	fi
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyrex/pyrex-0.9.9.ebuild,v 1.1 2010/04/13 15:56:07 arfrever Exp $

EAPI="3"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils multilib-native

MY_P="Pyrex-${PV}"

DESCRIPTION="A language for writing Python extension modules"
HOMEPAGE="http://www.cosc.canterbury.ac.nz/greg.ewing/python/Pyrex/"
SRC_URI="http://www.cosc.canterbury.ac.nz/greg.ewing/python/Pyrex/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="examples"

S="${WORKDIR}/${MY_P}"

PYTHON_MODNAME="Pyrex"

DEPEND=""
RDEPEND=""
RESTRICT_PYTHON_ABIS="3.*"

DOCS="CHANGES.txt ToDo.txt USAGE.txt"

multilib-native_src_install_internal() {
	distutils_src_install

	dohtml -A c -r Doc/*

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r Demos
	fi
}

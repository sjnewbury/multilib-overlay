# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyrex/pyrex-0.9.4.1.ebuild,v 1.11 2006/10/20 20:35:40 kloeri Exp $

inherit distutils portability multilib-native

MY_P="Pyrex-${PV}"
DESCRIPTION="a language for writing Python extension modules"
HOMEPAGE="http://www.cosc.canterbury.ac.nz/~greg/python/Pyrex"
SRC_URI="http://www.cosc.canterbury.ac.nz/~greg/python/Pyrex/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

S=${WORKDIR}/${MY_P}

PYTHON_MODNAME="Pyrex"

multilib-native_src_install_internal() {
	DOCS="CHANGES.txt INSTALL.txt ToDo.txt USAGE.txt"
	distutils_src_install

	dohtml -r Doc/*
	cp Doc/primes.c "${D}/usr/share/doc/${PF}/html/"
	treecopy Demos "${D}/usr/share/doc/${PF}"
}

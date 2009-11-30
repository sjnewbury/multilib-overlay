# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libdaemon/libdaemon-0.13-r1.ebuild,v 1.7 2009/11/17 19:57:36 ranger Exp $

inherit libtool eutils multilib-native

DESCRIPTION="Simple library for creating daemon processes in C"
HOMEPAGE="http://0pointer.de/lennart/projects/libdaemon/"
SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ~ia64 ~mips ppc ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd"
IUSE="doc examples"

RDEPEND=""
DEPEND="doc? ( app-doc/doxygen )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-bsd.patch"
	elibtoolize
}

multilib-native_src_compile_internal() {
	econf --disable-lynx --localstatedir=/var
	emake || die "emake failed"

	if use doc ; then
		einfo "Building documentation"
		make doxygen || die "make doxygen failed"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"

	if use doc; then
		ln -sf doc/reference/html reference
		dohtml -r doc/README.html reference
		doman doc/reference/man/man*/*
	fi

	if use examples; then
		docinto examples
		dodoc examples/testd.c
	fi

	dodoc README
}

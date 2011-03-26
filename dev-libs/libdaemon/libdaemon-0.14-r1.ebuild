# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libdaemon/libdaemon-0.14-r1.ebuild,v 1.6 2011/03/05 12:29:31 armin76 Exp $

inherit libtool eutils multilib-native

DESCRIPTION="Simple library for creating daemon processes in C"
HOMEPAGE="http://0pointer.de/lennart/projects/libdaemon/"
SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="doc examples"

RDEPEND=""
DEPEND="doc? ( app-doc/doxygen )"

multilib-native_src_compile_internal() {
	econf \
		--docdir=/usr/share/doc/${PF} \
		--localstatedir=/var \
		--disable-examples \
		--disable-lynx
	emake || die "emake failed"

	if use doc ; then
		einfo "Building documentation"
		emake doxygen || die "make doxygen failed"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"

	if use doc; then
		ln -sf doc/reference/html reference
		dohtml -r doc/README.html doc/style.css reference || die "dohtml failed"
		doman doc/reference/man/man*/* || die "doman failed"
	fi

	if use examples; then
		docinto examples
		dodoc examples/testd.c || die "dodoc 1 failed"
	fi

	rm -rf "${D}"/usr/share/doc/${PF}/{README.html,style.css} || die "rm failed"
	dodoc README || die "dodoc 2 failed"
}

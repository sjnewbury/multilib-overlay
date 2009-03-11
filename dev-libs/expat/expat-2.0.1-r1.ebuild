# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/expat/expat-2.0.1-r1.ebuild,v 1.8 2009/02/20 18:02:39 armin76 Exp $

inherit eutils libtool multilib-xlibs

DESCRIPTION="XML parsing libraries"
HOMEPAGE="http://expat.sourceforge.net/"
SRC_URI="mirror://sourceforge/expat/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fix segmentation fault in python tests (bug #197043)
	epatch "${FILESDIR}/${P}-check_stopped_parser.patch"

	elibtoolize
}

multilib-xlibs_src_install_internal() {
	make install DESTDIR="${D}" || die
	cd "${S}"
	dodoc Changes README
	dohtml doc/*
}

pkg_postinst() {
	ewarn "Please note that the soname of the library changed!"
	ewarn "If you are upgrading from a previous version you need"
	ewarn "to fix dynamic linking inconsistencies by executing:"
	ewarn "revdep-rebuild -X --library libexpat.so.0"
}

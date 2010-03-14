# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/expat/expat-2.0.1-r2.ebuild,v 1.9 2009/09/10 10:40:02 ssuominen Exp $

inherit eutils libtool multilib-native

DESCRIPTION="XML parsing libraries"
HOMEPAGE="http://expat.sourceforge.net/"
SRC_URI="mirror://sourceforge/expat/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND=""

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"

	# fix segmentation fault in python tests (bug #197043)
	epatch "${FILESDIR}/${P}-check_stopped_parser.patch"

	epatch "${FILESDIR}/${P}-fix_bug_1990430.patch"

	elibtoolize
	epunt_cxx
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "emake install failed"
	dodoc Changes README || die "dodoc failed"
	dohtml doc/* || die "dohtml failed"
}

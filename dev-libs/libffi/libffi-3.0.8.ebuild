# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libffi/libffi-3.0.8.ebuild,v 1.26 2009/12/20 16:16:31 armin76 Exp $

inherit autotools eutils multilib-native

DESCRIPTION="a portable, high level programming interface to various calling conventions."
HOMEPAGE="http://sourceware.org/libffi"
SRC_URI="ftp://sourceware.org/pub/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="debug static-libs test"

RDEPEND=""
DEPEND="!<dev-libs/g-wrap-1.9.11
	test? ( dev-util/dejagnu )"

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-fbsd.patch \
		"${FILESDIR}"/${P}-autoconf-2.64.patch \
		"${FILESDIR}"/${P}-arm.patch
	eautoreconf
}

multilib-native_src_compile_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable debug)
	emake || die
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog* README TODO
}

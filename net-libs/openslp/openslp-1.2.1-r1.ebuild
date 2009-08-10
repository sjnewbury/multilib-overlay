# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/openslp/openslp-1.2.1-r1.ebuild,v 1.2 2007/10/14 07:55:57 genstef Exp $

EAPI=2

WANT_AUTOMAKE="1.8"
WANT_AUTOCONF="latest"

inherit libtool eutils autotools multilib-native

DESCRIPTION="An open-source implementation of Service Location Protocol"
HOMEPAGE="http://www.openslp.org/"
SRC_URI="mirror://sourceforge/openslp/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE=""
RESTRICT="test"

DEPEND="dev-libs/openssl[lib32?]"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-fbsd.patch
	eautomake

	elibtoolize
}

multilib-native_src_compile_internal() {
	emake -j1 || die "make failed"
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS FAQ ChangeLog NEWS README* THANKS
	rm -rf "${D}"/usr/doc
	dohtml -r .
	newinitd "${FILESDIR}"/slpd-init slpd
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/openslp/openslp-1.2.1-r1.ebuild,v 1.4 2010/12/02 01:15:14 flameeyes Exp $

EAPI="2"

inherit eutils autotools multilib-native

DESCRIPTION="An open-source implementation of Service Location Protocol"
HOMEPAGE="http://www.openslp.org/"
SRC_URI="mirror://sourceforge/openslp/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""
RESTRICT="test"

DEPEND="dev-libs/openssl[lib32?]"
RDEPEND="${DEPEND}"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-fbsd.patch
	eautoreconf
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

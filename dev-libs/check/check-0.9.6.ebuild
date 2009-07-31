# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/check/check-0.9.6.ebuild,v 1.1 2009/06/09 03:15:00 jer Exp $

inherit eutils autotools multilib-native

DESCRIPTION="A unit test framework for C"
HOMEPAGE="http://sourceforge.net/projects/check/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-AM_PATH_CHECK.patch
	epatch "${FILESDIR}"/${P}-64bitsafe.patch

	sed -i -e '/^docdir =/d' Makefile.am doc/Makefile.am \
		|| die "Unable to remove docdir references"

	eautoreconf
}

ml-native_src_compile() {
	econf --docdir=/usr/share/doc/${PF}
	emake || die
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die
}

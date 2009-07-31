# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmng/libmng-1.0.9-r1.ebuild,v 1.15 2008/05/31 16:41:26 drac Exp $

EAPI="2"

WANT_AUTOCONF=2.5
WANT_AUTOMAKE=1.9
inherit autotools multilib-native

DESCRIPTION="Multiple Image Networkgraphics lib (animated png's)"
HOMEPAGE="http://www.libmng.com/"
SRC_URI="mirror://sourceforge/libmng/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="lcms"

DEPEND=">=media-libs/jpeg-6b[$(get_ml_usedeps)?]
	>=sys-libs/zlib-1.1.4[$(get_ml_usedeps)?]
	lcms? ( >=media-libs/lcms-1.0.8 )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	ln -s makefiles/configure.in .
	ln -s makefiles/Makefile.am .

	eautoreconf
}

src_configure() { :; }

ml-native_src_compile() {
	econf --with-jpeg $(use_with lcms) || die
	emake || die
}

ml-native_src_install() {
	make DESTDIR="${D}" install || die

	dodoc CHANGES README*
	dodoc doc/doc.readme doc/libmng.txt
	doman doc/man/*
}

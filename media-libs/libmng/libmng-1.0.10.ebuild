# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmng/libmng-1.0.10.ebuild,v 1.8 2008/11/09 12:00:46 vapier Exp $

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

DEPEND=">=media-libs/jpeg-6b[lib32?]
	>=sys-libs/zlib-1.1.4[lib32?]
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
	econf --with-jpeg $(use_with lcms) || die "econf failed"
	emake || die "emake failed"
}

ml-native_src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc CHANGES README*
	dodoc doc/doc.readme doc/libmng.txt
	doman doc/man/*
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmng/libmng-1.0.10.ebuild,v 1.10 2010/01/22 17:02:26 ssuominen Exp $

EAPI=2

WANT_AUTOCONF=2.5
WANT_AUTOMAKE=1.9
inherit autotools multilib-native

DESCRIPTION="Multiple Image Networkgraphics lib (animated png's)"
HOMEPAGE="http://www.libmng.com/"
SRC_URI="mirror://sourceforge/libmng/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="lcms"

DEPEND=">=media-libs/jpeg-6b:0[lib32?]
	>=sys-libs/zlib-1.1.4[lib32?]
	lcms? ( >=media-libs/lcms-1.0.8[lib32?] )"

multilib-native_src_prepare_internal() {
	ln -s makefiles/configure.in .
	ln -s makefiles/Makefile.am .

	eautoreconf
}

multilib-native_src_configure_internal() {
	econf --with-jpeg $(use_with lcms) || die "econf failed"
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc CHANGES README*
	dodoc doc/doc.readme doc/libmng.txt
	doman doc/man/*
}

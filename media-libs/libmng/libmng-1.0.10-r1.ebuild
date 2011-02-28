# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmng/libmng-1.0.10-r1.ebuild,v 1.2 2011/02/19 18:31:42 ssuominen Exp $

EAPI=3
inherit autotools multilib-native

DESCRIPTION="Multiple Image Networkgraphics lib (animated png's)"
HOMEPAGE="http://www.libmng.com/"
SRC_URI="mirror://sourceforge/libmng/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="lcms static-libs"

RDEPEND="virtual/jpeg[lib32?]
	>=sys-libs/zlib-1.1.4[lib32?]
	lcms? ( =media-libs/lcms-1*[lib32?] )"
DEPEND="${RDEPEND}"

multilib-native_src_prepare_internal() {
	ln -s makefiles/configure.in .
	ln -s makefiles/Makefile.am .

	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		--with-jpeg \
		$(use_with lcms)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die

	use static-libs || find "${ED}" -name '*.la' -exec rm -f {} +

	dodoc CHANGES README*
	dodoc doc/doc.readme doc/libmng.txt
	doman doc/man/*
}

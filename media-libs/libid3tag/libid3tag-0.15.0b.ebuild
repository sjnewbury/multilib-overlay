# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libid3tag/libid3tag-0.15.0b.ebuild,v 1.19 2006/03/06 15:12:52 flameeyes Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="The MAD id3tag library"
HOMEPAGE="http://mad.sourceforge.net"
SRC_URI="mirror://sourceforge/mad/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc sparc x86"
IUSE="debug"

DEPEND=">=sys-libs/zlib-1.1.3[lib32?]"

multilib-native_src_configure_internal() {
	econf $(use_enable debug debugging) || die "configure failed"
}

multilib-native_src_compile_internal() {
	emake || die "make failed"
}

multilib-native_src_install_internal() {
	einstall || die "make install failed"

	dodoc CHANGES CREDITS README TODO VERSION

	# This file must be updated with every version update
	dodir /usr/lib/pkgconfig
	insinto /usr/lib/pkgconfig
	doins ${FILESDIR}/id3tag.pc
}

# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdca/libdca-0.0.5.ebuild,v 1.21 2007/12/29 11:25:28 vapier Exp $

inherit eutils toolchain-funcs autotools multilib-native

DESCRIPTION="library for decoding DTS Coherent Acoustics streams used in DVD"
HOMEPAGE="http://www.videolan.org/developers/libdca.html"
SRC_URI="http://www.videolan.org/pub/videolan/${PN}/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="oss debug"

RDEPEND="!media-libs/libdts"

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-cflags.patch
	eautoreconf
}

multilib-native_src_compile_internal() {
	econf $(use_enable oss) $(use_enable debug)
	emake OPT_CFLAGS="" || die "emake failed."
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO doc/${PN}.txt
}

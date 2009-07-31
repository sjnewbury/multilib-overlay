# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/a52dec/a52dec-0.7.4-r5.ebuild,v 1.19 2008/06/13 14:06:16 loki_val Exp $

EAPI="2"

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit eutils flag-o-matic libtool autotools multilib-native

DESCRIPTION="library for decoding ATSC A/52 streams used in DVD"
HOMEPAGE="http://liba52.sourceforge.net/"
SRC_URI="http://liba52.sourceforge.net/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="oss djbfft"

RDEPEND="djbfft? ( sci-libs/djbfft[lib32?] )"
DEPEND="${RDEPEND}"

ml-native_src_prepare() {
	epatch "${FILESDIR}/${P}-build.patch"
	epatch "${FILESDIR}/${P}-freebsd.patch"

	eautoreconf
	epunt_cxx
}

ml-native_src_configure() {
	filter-flags -fprefetch-loop-arrays

	local myconf="--enable-shared"
	use oss || myconf="${myconf} --disable-oss"
	econf \
		$(use_enable djbfft) \
		${myconf} || die
}

ml-native_src_compile() {
	emake CFLAGS="${CFLAGS}" || die "emake failed"
}

ml-native_src_install() {
	make DESTDIR="${D}" docdir=/usr/share/doc/${PF}/html install || die

	insinto /usr/include/a52dec
	doins "${S}"/liba52/a52_internal.h

	dodoc AUTHORS ChangeLog HISTORY NEWS README TODO doc/liba52.txt
}

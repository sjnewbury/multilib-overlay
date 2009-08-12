# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/babl/babl-0.0.22.ebuild,v 1.12 2009/07/06 21:56:22 jer Exp $

inherit autotools multilib-native

DESCRIPTION="A dynamic, any to any, pixel format conversion library"
HOMEPAGE="http://www.gegl.org/babl/"
SRC_URI="ftp://ftp.gtk.org/pub/${PN}/0.1/${P}.tar.bz2"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ~ppc64 sparc x86"
IUSE="sse mmx"

DEPEND="virtual/libc"

multilib-native_src_unpack_internal() {
	unpack "${A}"
	cd "${S}"
	epatch "${FILESDIR}/${P}-fix-DESTDIR.patch"
	epatch "${FILESDIR}/${P}-ext-avoid-version.patch"
	eautoreconf
}

multilib-native_src_compile_internal() {
	econf $(use_enable mmx) \
		$(use_enable sse) \
		|| die "econf failed"
	emake || die "emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	find "${D}" -name '*.la' -delete
	dodoc AUTHORS ChangeLog README NEWS || die "dodoc failed"
}

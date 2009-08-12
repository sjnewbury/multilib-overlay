# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/babl/babl-0.0.22.ebuild,v 1.12 2009/07/06 21:56:22 jer Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="A dynamic, any to any, pixel format conversion library"
HOMEPAGE="http://www.gegl.org/babl/"
SRC_URI="ftp://ftp.gtk.org/pub/${PN}/0.0/${P}.tar.bz2"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ~ppc64 sparc x86"
IUSE="sse mmx"

DEPEND="virtual/libc"

multilib-native_src_configure_internal() {
	econf $(use_enable mmx) \
		$(use_enable sse) \
		|| die "econf failed"
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "emake install failed"
	find "${D}" -name '*.la' -delete
	dodoc AUTHORS ChangeLog README NEWS || die "dodoc failed"
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/babl/babl-0.1.0.ebuild,v 1.2 2009/09/23 15:22:47 ssuominen Exp $

EAPI="2"

inherit eutils autotools multilib-native

DESCRIPTION="A dynamic, any to any, pixel format conversion library"
HOMEPAGE="http://www.gegl.org/babl/"
SRC_URI="ftp://ftp.gtk.org/pub/${PN}/${PV:0:3}/${P}.tar.bz2"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="sse mmx"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${P}-build-fixes.patch"
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		$(use_enable mmx) \
		$(use_enable sse)
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "emake install failed"
	find "${D}" -name '*.la' -delete
	dodoc AUTHORS ChangeLog README NEWS || die "dodoc failed"
}

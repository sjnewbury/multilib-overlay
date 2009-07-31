# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdv/libdv-1.0.0-r2.ebuild,v 1.10 2008/01/03 14:02:26 aballier Exp $

EAPI="2"

inherit eutils flag-o-matic libtool multilib-native

DESCRIPTION="Software codec for dv-format video (camcorders etc)"
HOMEPAGE="http://libdv.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	mirror://gentoo/${PN}-1.0.0-pic.patch.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="debug sdl xv"

RDEPEND="dev-libs/popt
	sdl? ( >=media-libs/libsdl-1.2.5[$(get_ml_usedeps)] )
	xv? ( x11-libs/libXv[$(get_ml_usedeps)] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)]"

ml-native_src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.99-2.6.patch
	epatch "${WORKDIR}"/${PN}-1.0.0-pic.patch
	elibtoolize
	epunt_cxx #74497
}

ml-native_src_configure() {
	econf \
		$(use_with debug) \
		--disable-gtk --disable-gtktest \
		$(use_enable sdl) \
		$(use_enable xv) \
		|| die "econf failed."
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog INSTALL NEWS README* TODO
}

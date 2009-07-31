# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sdl-image/sdl-image-1.2.7.ebuild,v 1.8 2009/04/30 12:27:38 jer Exp $

EAPI="2"

inherit multilib-native

MY_P="${P/sdl-/SDL_}"
DESCRIPTION="image file loading library"
HOMEPAGE="http://www.libsdl.org/projects/SDL_image/index.html"
SRC_URI="http://www.libsdl.org/projects/SDL_image/release/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="gif jpeg tiff png"

DEPEND="sys-libs/zlib[$(get_ml_usedeps)?]
	>=media-libs/libsdl-1.2.10[$(get_ml_usedeps)?]
	png? ( >=media-libs/libpng-1.2.1[$(get_ml_usedeps)?] )
	jpeg? ( >=media-libs/jpeg-6b[$(get_ml_usedeps)?] )
	tiff? ( media-libs/tiff[$(get_ml_usedeps)?] )"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

ml-native_src_configure() {
	econf \
		$(use_enable gif) \
		$(use_enable jpeg jpg) \
		$(use_enable tiff tif) \
		$(use_enable png) \
		$(use_enable png pnm) \
		--enable-bmp \
		--enable-lbm \
		--enable-pcx \
		--enable-tga \
		--enable-xcf \
		--enable-xpm \
		|| die
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dobin .libs/showimage || die "dobin failed"
	dodoc CHANGES README
}

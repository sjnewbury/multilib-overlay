# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sdl-image/sdl-image-1.2.9.ebuild,v 1.1 2009/11/13 03:50:21 vapier Exp $

EAPI="2"

inherit multilib-native

MY_P="${P/sdl-/SDL_}"
DESCRIPTION="image file loading library"
HOMEPAGE="http://www.libsdl.org/projects/SDL_image/"
SRC_URI="http://www.libsdl.org/projects/SDL_image/release/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="gif jpeg tiff png"

DEPEND="sys-libs/zlib[lib32?]
	media-libs/libsdl[lib32?]
	png? ( media-libs/libpng[lib32?] )
	jpeg? ( >=media-libs/jpeg-7[lib32?] )
	tiff? ( media-libs/tiff[lib32?] )"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

multilib-native_src_configure_internal() {
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

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dobin .libs/showimage || die "dobin failed"
	dodoc CHANGES README
}

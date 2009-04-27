# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sdl-ttf/sdl-ttf-2.0.9.ebuild,v 1.9 2008/05/13 17:00:03 jer Exp $

EAPI="2"

inherit multilib-native

MY_P="${P/sdl-/SDL_}"
DESCRIPTION="library that allows you to use TrueType fonts in SDL applications"
HOMEPAGE="http://www.libsdl.org/projects/SDL_ttf/"
SRC_URI="http://www.libsdl.org/projects/SDL_ttf/release/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="X"

DEPEND="X? ( x11-libs/libXt[lib32?] )
	media-libs/libsdl[lib32?]
	>=media-libs/freetype-2.3[lib32?]"

S=${WORKDIR}/${MY_P}

multilib-native_src_configure_internal() {
	econf $(use_with X x) || die "econf failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc CHANGES README
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sdl-net/sdl-net-1.2.7.ebuild,v 1.13 2010/07/27 00:52:41 mr_bones_ Exp $

EAPI=2

inherit multilib-native
MY_P=${P/sdl-/SDL_}
DESCRIPTION="Simple Direct Media Layer Network Support Library"
HOMEPAGE="http://www.libsdl.org/projects/SDL_net/index.html"
SRC_URI="http://www.libsdl.org/projects/SDL_net/release/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="static-libs"

DEPEND=">=media-libs/libsdl-1.2.5[lib32?]"

S=${WORKDIR}/${MY_P}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc CHANGES README
	if ! use static-libs ; then
		find "${D}" -type f -name '*.la' -exec rm {} + \
			|| die "la removal failed"
	fi
}

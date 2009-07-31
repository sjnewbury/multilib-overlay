# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sdl-net/sdl-net-1.2.7.ebuild,v 1.11 2008/09/27 16:13:25 armin76 Exp $

EAPI="2"

inherit multilib-native

MY_P=${P/sdl-/SDL_}
DESCRIPTION="Simple Direct Media Layer Network Support Library"
HOMEPAGE="http://www.libsdl.org/projects/SDL_net/index.html"
SRC_URI="http://www.libsdl.org/projects/SDL_net/release/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE=""

DEPEND=">=media-libs/libsdl-1.2.5[$(get_ml_usedeps)?]"

S=${WORKDIR}/${MY_P}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc CHANGES README
}

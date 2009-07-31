# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sdl-mixer/sdl-mixer-1.2.8.ebuild,v 1.10 2009/06/08 18:04:04 armin76 Exp $

EAPI="2"

inherit eutils multilib-native

MY_P=${P/sdl-/SDL_}
DESCRIPTION="Simple Direct Media Layer Mixer Library"
HOMEPAGE="http://www.libsdl.org/projects/SDL_mixer/index.html"
SRC_URI="http://www.libsdl.org/projects/SDL_mixer/release/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE="mp3 mikmod timidity vorbis"

DEPEND=">=media-libs/libsdl-1.2.10[lib32?]
	timidity? ( media-sound/timidity++ )
	mp3? ( >=media-libs/smpeg-0.4.4-r1[lib32?] )
	vorbis? ( >=media-libs/libvorbis-1.0_beta4[lib32?] media-libs/libogg[lib32?] )
	mikmod? ( >=media-libs/libmikmod-3.1.10[lib32?] )"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e 's:/usr/local/lib/timidity:/usr/share/timidity:' \
		timidity/config.h \
		|| die "sed timidity/config.h failed"
}

ml-native_src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable timidity music-midi) \
		$(use_enable timidity timidity-midi) \
		$(use_enable mikmod music-mod) \
		$(use_enable mikmod music-libmikmod) \
		$(use_enable mp3 music-mp3) \
		$(use_enable vorbis music-ogg) \
		|| die
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc CHANGES README
}

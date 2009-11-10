# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/sdl-mixer/sdl-mixer-1.2.10.ebuild,v 1.1 2009/11/09 12:41:41 vapier Exp $

EAPI="2"

inherit eutils multilib-native

MY_P=${P/sdl-/SDL_}
DESCRIPTION="Simple Direct Media Layer Mixer Library"
HOMEPAGE="http://www.libsdl.org/projects/SDL_mixer/"
SRC_URI="http://www.libsdl.org/projects/SDL_mixer/release/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="flac mad +midi mikmod mp3 timidity vorbis +wav"

DEPEND=">=media-libs/libsdl-1.2.10[lib32?]
	flac? ( media-libs/flac[lib32?] )
	timidity? ( media-sound/timidity++ )
	mad? ( media-libs/libmad[lib32?] )
	!mad? ( mp3? ( >=media-libs/smpeg-0.4.4-r1[lib32?] ) )
	vorbis? ( >=media-libs/libvorbis-1.0_beta4[lib32?] media-libs/libogg[lib32?] )
	mikmod? ( >=media-libs/libmikmod-3.1.10[lib32?] )"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	# this guy breaks SONAME by accident -- fix is in upstream
	sed -i '/^BINARY_AGE=/s:=.*:=10:' configure
}

multilib-native_src_configure_internal() {
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

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc CHANGES README
}

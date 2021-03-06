# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg123/mpg123-1.12.1.ebuild,v 1.10 2010/06/24 16:36:11 armin76 Exp $

EAPI=2
inherit toolchain-funcs multilib-native

DESCRIPTION="a realtime MPEG 1.0/2.0/2.5 audio player for layers 1, 2 and 3"
HOMEPAGE="http://www.mpg123.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2
	http://www.mpg123.org/download/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="3dnow 3dnowext alsa altivec ipv6 jack mmx nas oss portaudio pulseaudio sdl sse"

RDEPEND="alsa? ( media-libs/alsa-lib[lib32?] )
	jack? ( media-sound/jack-audio-connection-kit[lib32?] )
	nas? ( media-libs/nas[lib32?] )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio[lib32?] )
	sdl? ( media-libs/libsdl[lib32?] )
	sys-devel/libtool[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

multilib-native_src_configure_internal() {
	local _audio=dummy
	local _output=dummy
	local _cpu=generic_fpu

	for flag in nas portaudio sdl oss jack alsa pulseaudio; do
		if use ${flag}; then
			_audio="${_audio} ${flag/pulseaudio/pulse}"
			_output=${flag/pulseaudio/pulse}
		fi
	done

	use altivec && _cpu=altivec

	if [[ $(tc-arch) == amd64 ]]; then
		use sse && _cpu=x86-64
	else
		use mmx && _cpu=mmx
		use 3dnow && _cpu=3dnow
		use sse && _cpu=x86
		use 3dnowext && _cpu=x86
	fi

	econf \
		--disable-dependency-tracking \
		--with-optimization=0 \
		--with-audio="${_audio}" \
		--with-default-audio=${_output} \
		--with-cpu=${_cpu} \
		--enable-network \
		$(use_enable ipv6)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS* README
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg123/mpg123-1.7.3-r1.ebuild,v 1.1 2009/06/21 07:35:10 ssuominen Exp $

EAPI=2

inherit multilib-native

DESCRIPTION="a realtime MPEG 1.0/2.0/2.5 audio player for layers 1, 2 and 3."
HOMEPAGE="http://www.mpg123.org"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="3dnow 3dnowext alsa altivec ipv6 jack mmx nas +network oss portaudio pulseaudio sdl sse"

RDEPEND="alsa? ( media-libs/alsa-lib[lib32?] )
	jack? ( media-sound/jack-audio-connection-kit[lib32?] )
	nas? ( media-libs/nas[lib32?] )
	portaudio? ( media-libs/portaudio[lib32?] )
	pulseaudio? ( media-sound/pulseaudio[lib32?] )
	sdl? ( media-libs/libsdl[lib32?] )
	!>media-sound/mpg321-0.2.10-r3[symlink]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"
PDEPEND="virtual/mpg123"

multilib-native_pkg_setup_internal() {
	# Make sure there is no mpg123 symlink left
	local link="${ROOT}usr/bin/mpg123"
	local msg="Removing invalid symlink ${link}"
	if [ -L "${link}" ] && [ ! -x "${link}" ]; then
		ebegin "${msg}"
		rm -f "${link}" || die "${msg} failed, please open a bug."
		eend $?
	fi
}

multilib-native_src_prepare_internal() {
	sed -i -e 's:-faltivec::' configure || die "sed failed"
}

multilib-native_src_configure_internal() {
	local myaudio

	use alsa && myaudio="${myaudio} alsa"
	use jack && myaudio="${myaudio} jack"
	use nas && myaudio="${myaudio} nas"
	use oss && myaudio="${myaudio} oss"
	use portaudio && myaudio="${myaudio} portaudio"
	use pulseaudio && myaudio="${myaudio} pulse"
	use sdl && myaudio="${myaudio} sdl"

	local mycpu

	if use altivec; then
		mycpu="--with-cpu=altivec"
	elif use 3dnowext; then
		mycpu="--with-cpu=3dnowext"
	elif use 3dnow; then
		mycpu="--with-cpu=3dnow"
	elif use sse; then
		mycpu="--with-cpu=sse"
	elif use mmx; then
		mycpu="--with-cpu=mmx"
	fi

	econf \
		--disable-dependency-tracking \
		--with-optimization=0 ${mycpu} \
		--with-audio="${myaudio}" \
		$(use_enable network) \
		$(use_enable ipv6)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS* README
}

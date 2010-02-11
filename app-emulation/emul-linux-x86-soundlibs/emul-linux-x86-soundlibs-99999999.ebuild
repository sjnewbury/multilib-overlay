# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* ~amd64"
SLOT="0"
IUSE="-nodep"

RDEPEND="!nodep? ( =app-emulation/emul-linux-x86-baselibs-${PV}
		=app-emulation/emul-linux-x86-medialibs-${PV}
		=app-emulation/emul-linux-x86-xlibs-${PV}
		dev-libs/liboil[lib32]
		media-libs/alsa-lib[lib32]
		media-libs/alsa-oss[lib32]
		media-libs/audiofile[lib32]
		media-libs/flac[lib32]
		media-libs/libmikmod[lib32]
		media-libs/libmodplug[lib32]
		media-libs/libogg[lib32]
		media-libs/libsndfile[lib32]
		media-libs/libvorbis[lib32]
		media-libs/portaudio[lib32]
		media-sound/esound[lib32]
		media-sound/jack-audio-connection-kit[lib32]
		media-sound/pulseaudio[lib32]"

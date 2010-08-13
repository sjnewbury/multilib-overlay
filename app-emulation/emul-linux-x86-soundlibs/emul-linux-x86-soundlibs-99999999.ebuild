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
		dev-libs/liboil[multilib_abi_x86]
		media-libs/alsa-lib[multilib_abi_x86]
		media-libs/alsa-oss[multilib_abi_x86]
		media-libs/audiofile[multilib_abi_x86]
		media-libs/flac[multilib_abi_x86]
		media-libs/libmikmod[multilib_abi_x86]
		media-libs/libmodplug[multilib_abi_x86]
		media-libs/libogg[multilib_abi_x86]
		media-libs/libsndfile[multilib_abi_x86]
		media-libs/libvorbis[multilib_abi_x86]
		media-libs/portaudio[multilib_abi_x86]
		media-sound/esound[multilib_abi_x86]
		media-sound/jack-audio-connection-kit[multilib_abi_x86]
		media-sound/pulseaudio[multilib_abi_x86] )"

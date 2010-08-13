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
		=app-emulation/emul-linux-x86-soundlibs-${PV}
		=app-emulation/emul-linux-x86-xlibs-${PV}
		=app-emulation/emul-linux-x86-sdl-${PV}
		!<media-video/mplayer-bin-1.0_rc1-r2
		media-libs/libtheora[multilib_abi_x86]
		media-libs/libmad[multilib_abi_x86]
		media-sound/lame[multilib_abi_x86]
		dev-libs/DirectFB[multilib_abi_x86]
		app-misc/lirc[multilib_abi_x86]
		media-libs/xvid[multilib_abi_x86]
		dev-libs/fribidi[multilib_abi_x86]
		media-libs/libdv[multilib_abi_x86] )"

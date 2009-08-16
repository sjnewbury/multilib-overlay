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
		media-libs/libtheora[lib32]
		media-libs/libmad[lib32]
		media-sound/lame[lib32]
		dev-libs/DirectFB[lib32]
		app-misc/lirc[lib32]
		media-libs/xvid[lib32]
		dev-libs/fribidi[lib32]
		media-libs/libdv[lib32] )"

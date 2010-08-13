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
		media-libs/speex[multilib_abi_x86] )"

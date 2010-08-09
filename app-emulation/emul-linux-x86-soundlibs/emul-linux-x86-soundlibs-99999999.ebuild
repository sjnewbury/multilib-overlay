# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* amd64 amd64-linux"
SLOT="0"
IUSE="-nodep +alsa"


RDEPEND="
!nodep? (
	>=app-emulation/emul-linux-x86-baselibs-20081109
	>=app-emulation/emul-linux-x86-medialibs-20081109
	>=app-emulation/emul-linux-x86-xlibs-20081109
)
"

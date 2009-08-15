# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* amd64"
SLOT="0"
IUSE="-nodep xfce"

RDEPEND="!nodep? ( dev-libs/atk[lib32]
		x11-libs/cairo[lib32]
		x11-libs/gtk+[lib32]
		x11-libs/pango[lib32]
		x11-themes/gtk-engines[lib32]
		xfce? ( x11-themes/gtk-engines-xfce[lib32] ) )"

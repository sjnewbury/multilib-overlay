# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Metapackage to provide 32bit libraries via multilib"
HOMEPAGE="http://www.gentoo.org/"
LICENSE="GPL-2"

KEYWORDS="-* amd64"
SLOT="0"
IUSE="-nodep kerberos xfce"


RDEPEND="
!nodep? (
	dev-libs/atk[$(get_ml_usedeps)]
	x11-libs/cairo[$(get_ml_usedeps)]
	x11-libs/gtk+[$(get_ml_usedeps)]
	x11-libs/pango[$(get_ml_usedeps)]
	x11-themes/gtk-engines[$(get_ml_usedeps)]
	xfce? ( x11-themes/gtk-engines-xfce[$(get_ml_usedeps)] )
)
"

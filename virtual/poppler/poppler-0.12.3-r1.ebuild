# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/poppler/poppler-0.12.3-r1.ebuild,v 1.2 2010/01/24 22:37:58 yngwin Exp $

EAPI=2

DESCRIPTION="Virtual package, includes packages that contain libpoppler.so"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="lcms lib32"

PROPERTIES="virtual"

RDEPEND="~app-text/poppler-${PV}[lcms?,xpdf-headers]"
DEPEND="${RDEPEND}"

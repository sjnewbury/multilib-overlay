# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/poppler/poppler-0.12.3-r1.ebuild,v 1.9 2010/02/08 18:19:40 nixnut Exp $

EAPI=2

DESCRIPTION="Virtual package, includes packages that contain libpoppler.so"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+lcms"

PROPERTIES="virtual lib32"

RDEPEND="~app-text/poppler-${PV}[lcms?,xpdf-headers,lib32?]"
DEPEND="${RDEPEND}"

# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/glut/glut-1.0.ebuild,v 1.6 2008/01/25 19:40:00 grobian Exp $

DESCRIPTION="Virtual for OpenGL utility toolkit"
HOMEPAGE="http://www.gentoo.org/proj/en/desktop/x/x11/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="lib32"
RDEPEND="|| ( media-libs/freeglut[lib32?] media-libs/glut[lib32?] )"
DEPEND=""

# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/opengl/opengl-7.0.ebuild,v 1.10 2006/08/23 21:23:14 swegener Exp $

DESCRIPTION="Virtual for OpenGL implementation"
HOMEPAGE="http://www.gentoo.org/proj/en/desktop/x/x11/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="lib32"
RDEPEND="media-libs/mesa[$(get_ml_usedeps)?]"
DEPEND=""

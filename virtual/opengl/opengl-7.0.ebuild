# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/opengl/opengl-7.0.ebuild,v 1.14 2011/02/06 12:01:28 leio Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Virtual for OpenGL implementation"
HOMEPAGE=""
SRC_URI=""
LICENSE=""
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
RDEPEND="|| ( media-libs/mesa[lib32?] media-libs/opengl-apple )"
DEPEND=""

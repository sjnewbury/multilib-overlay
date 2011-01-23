# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/tex-base/tex-base-0.ebuild,v 1.5 2010/01/11 11:15:20 ulm Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Virtual for basic TeX binaries (tex, kpathsea)"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="|| (
		app-text/texlive-core[lib32?]
		app-text/ptex
	)"

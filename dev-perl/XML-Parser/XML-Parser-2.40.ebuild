# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-Parser/XML-Parser-2.40.ebuild,v 1.1 2010/09/16 06:30:27 tove Exp $

EAPI=3

MODULE_AUTHOR=CHORNY
inherit perl-module multilib multilib-native

DESCRIPTION="A Perl extension interface to James Clark's XML parser, expat"

SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/expat-1.95.1-r1[lib32?]"
DEPEND="${RDEPEND}"

SRC_TEST=do
myconf="EXPATLIBPATH='${EPREFIX}/usr/$(get_libdir)' EXPATINCPATH='${EPREFIX}/usr/include'"

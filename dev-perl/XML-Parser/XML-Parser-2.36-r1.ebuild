# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-Parser/XML-Parser-2.36-r1.ebuild,v 1.8 2010/11/05 14:14:30 ssuominen Exp $

EAPI="2"

MODULE_AUTHOR=MSERGEANT
inherit perl-module multilib multilib-native

DESCRIPTION="A Perl extension interface to James Clark's XML parser, expat"

SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-libs/expat-1.95.1-r1[lib32?]
	dev-lang/perl[lib32?]"

multilib-native_src_prepare_internal() {
	sed -i \
		-e "s:^\$expat_libpath.*:\$expat_libpath = '${EPREFIX}/usr/$(get_libdir)';:" \
		Makefile.PL || die "sed failed"
}

# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libedit/libedit-20050930.ebuild,v 1.7 2011/02/06 12:37:00 leio Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="BSD replacement for libreadline"
HOMEPAGE="http://cvsweb.netbsd.org/bsdweb.cgi/src/lib/libedit/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh x86"
IUSE=""
RESTRICT="test"

DEPEND="sys-libs/ncurses[lib32?]"

S=${WORKDIR}/netbsd-cvs

multilib-native_src_prepare_internal() {
	mv "${WORKDIR}"/glibc-*/*.c .
	epatch "${FILESDIR}"/${PN}-20050531-debian-to-gentoo.patch
}

multilib-native_src_compile_internal() {
	emake -j1 .depend || die "depend"
	emake || die "make"
}

multilib-native_src_install_internal() {
	dolib.so libedit.so || die "dolib.so"
	dolib.a libedit.a || die "dolib.a"
	insinto /usr/include
	doins histedit.h || die "doins *.h"
	doman *.[35]
}

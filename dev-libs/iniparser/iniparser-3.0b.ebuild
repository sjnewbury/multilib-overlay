# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/iniparser/iniparser-3.0b.ebuild,v 1.2 2008/08/15 15:46:03 dev-zero Exp $

inherit multilib toolchain-funcs multilib-native

MY_P="${PN}${PV}"

DESCRIPTION="A ree stand-alone ini file parsing library."
HOMEPAGE="http://ndevilla.free.fr/iniparser/"
SRC_URI="http://ndevilla.free.fr/iniparser/${MY_P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

multilib-native_src_compile_internal() {
	sed -i \
		-e "s|\(CFLAGS  =\) -O2|\1 ${CFLAGS}|" \
		-e "s|\(LDFLAGS =\)|\1 ${LDFLAGS}|" \
		-e "s|/usr/lib|/usr/$(get_libdir)|" \
		Makefile || die "sed failed"

	emake CC=$(tc-getCC) AR="$(tc-getAR)" || die "emake failed"
}

multilib-native_src_install_internal() {
	dolib libiniparser.a libiniparser.so.0
	dosym libiniparser.so.0 /usr/$(get_libdir)/libiniparser.so

	insinto /usr/include
	doins src/*.h

	dodoc AUTHORS README
	dohtml html/*
}

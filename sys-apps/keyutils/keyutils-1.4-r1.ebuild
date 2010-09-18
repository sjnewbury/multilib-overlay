# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/keyutils/keyutils-1.4-r1.ebuild,v 1.2 2010/09/17 09:13:01 haubi Exp $

EAPI=3

inherit multilib eutils toolchain-funcs multilib-native

DESCRIPTION="Linux Key Management Utilities"
HOMEPAGE="http://www.kernel.org/"
SRC_URI="http://people.redhat.com/~dhowells/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux"
IUSE=""

DEPEND="!prefix? ( >=sys-kernel/linux-headers-2.6.11 )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-1.2-makefile-fixup.patch
	sed -i \
		-e '/CFLAGS/s|:= -g -O2|+=|' \
		Makefile || die
}

multilib-native_src_configure_internal() {
	:
}

multilib-native_src_compile_internal() {
	emake \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		|| die "emake failed"
}

multilib-native_src_install_internal() {
	emake \
		DESTDIR="${ED}" \
		LIBDIR="/$(get_libdir)" \
		USRLIBDIR="/usr/$(get_libdir)" \
		install || die
	dodoc README

	gen_usr_ldscript libkeyutils.so
}

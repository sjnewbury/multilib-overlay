# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/c-ares/c-ares-1.5.3.ebuild,v 1.8 2010/12/11 09:43:37 dragonheart Exp $

inherit multilib-native

DESCRIPTION="C library that resolves names asynchronously"
HOMEPAGE="http://daniel.haxx.se/projects/c-ares/"
SRC_URI="http://daniel.haxx.se/projects/c-ares/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

DEPEND=""
RDEPEND=""

multilib-native_src_compile_internal() {
	econf --enable-shared || die
	emake || die
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc CHANGES NEWS README*

	prep_ml_includes
}

multilib-native_pkg_postinst_internal() {
	ewarn "The soname for libares has changed in c-ares-1.4.0."
	#ewarn "If you have upgraded from that or earlier version, it is recommended to run:"
	ewarn
	ewarn "revdep-rebuild --library libcares.so.1"
	ewarn
	ewarn "This will fix linking errors caused by this change."
	echo
}

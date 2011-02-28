# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/gdbm/gdbm-1.8.3-r3.ebuild,v 1.4 2011/02/06 21:35:09 leio Exp $

EAPI="2"

inherit eutils libtool multilib multilib-native

DESCRIPTION="Standard GNU database libraries"
HOMEPAGE="http://www.gnu.org/software/gdbm/gdbm.html"
SRC_URI="mirror://gnu/gdbm/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="berkdb"

DEPEND="berkdb? ( sys-libs/db[lib32?] )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-fix-install-ownership.patch #24178
	epatch "${FILESDIR}"/${P}-compat-linking.patch #165263
	elibtoolize
}

multilib-native_src_configure_internal() {
	use berkdb || export ac_cv_lib_dbm_main=no ac_cv_lib_ndbm_main=no
	econf --includedir=/usr/include/gdbm || die
}

multilib-native_src_install_internal() {
	emake -j1 INSTALL_ROOT="${D}" install install-compat || die
	mv "${D}"/usr/include/gdbm/gdbm.h "${D}"/usr/include/ || die
	dodoc ChangeLog NEWS README
}

multilib-native_pkg_preinst_internal() {
	preserve_old_lib libgdbm.so.2 #32510
}

multilib-native_pkg_postinst_internal() {
	preserve_old_lib_notify libgdbm.so.2 #32510
}

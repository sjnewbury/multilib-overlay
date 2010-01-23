# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/gdbm/gdbm-1.8.3-r4.ebuild,v 1.9 2010/01/15 04:32:29 vapier Exp $

EAPI=2
inherit eutils libtool flag-o-matic multilib-native

DESCRIPTION="Standard GNU database libraries"
HOMEPAGE="http://www.gnu.org/software/gdbm/gdbm.html"
SRC_URI="mirror://gnu/gdbm/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="berkdb"

DEPEND="berkdb? ( sys-libs/db[lib32?] )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-fix-install-ownership.patch #24178
	epatch "${FILESDIR}"/${P}-compat-linking.patch #165263
	epatch "${FILESDIR}"/${P}-build.patch #209730
	elibtoolize
	append-lfs-flags
}

multilib-native_src_configure_internal() {
	use berkdb || export ac_cv_lib_dbm_main=no ac_cv_lib_ndbm_main=no
	econf \
		--includedir=/usr/include/gdbm \
		--disable-dependency-tracking \
		--enable-fast-install \
		|| die
}

multilib-native_src_install_internal() {
	emake -j1 INSTALL_ROOT="${D}" install install-compat || die
	mv "${D}"/usr/include/gdbm/gdbm.h "${D}"/usr/include/ || die
	dodoc ChangeLog NEWS README
}

pkg_preinst() {
	preserve_old_lib libgdbm.so.2 #32510
}

pkg_postinst() {
	preserve_old_lib_notify libgdbm.so.2 #32510

	ewarn "32bit systems might have to rebuild all gdbm databases due to"
	ewarn "LFS changes in the gdbm format.  You can either delete the db"
	ewarn "and regenerate it from scratch, or use the converter:"
	ewarn "http://bugs.gentoo.org/attachment.cgi?id=215326"
}

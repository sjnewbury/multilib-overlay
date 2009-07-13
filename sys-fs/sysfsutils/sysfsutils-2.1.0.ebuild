# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/sysfsutils/sysfsutils-2.1.0.ebuild,v 1.9 2007/12/16 12:34:09 armin76 Exp $

inherit multilib multilib-native

DESCRIPTION="System Utilities Based on Sysfs"
HOMEPAGE="http://linux-diag.sourceforge.net/Sysfsutils.html"
SRC_URI="mirror://sourceforge/linux-diag/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86"
IUSE=""

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS CREDITS ChangeLog NEWS README TODO docs/libsysfs.txt

	# We do not distribute this
	rm -f "${D}"/usr/bin/dlist_test

	# Move shared libs to /
	dodir /$(get_libdir)
	mv "${D}"/usr/$(get_libdir)/lib*.so* "${D}"/$(get_libdir)/ || die
	gen_usr_ldscript libsysfs.so
}

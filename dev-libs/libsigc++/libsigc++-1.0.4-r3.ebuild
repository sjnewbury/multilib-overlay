# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libsigc++/libsigc++-1.0.4-r3.ebuild,v 1.15 2010/09/13 11:40:08 pacho Exp $

inherit eutils multilib-native

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="http://libsigc.sourceforge.net/"
SRC_URI="http://download.sourceforge.net/libsigc/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="1.0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc sh sparc x86"
IUSE="debug"

DEPEND=""

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-gcc43.patch

	# fix --as-needed, see bug #140248
	sed -i -e 's:^libsigc_la_LIBADD =:& $(THREAD_LIB):' \
		sigc++/Makefile.in || die

	# Respect LDFLAGS, bug #336827
	sed -i "/CC\|LD/{s/-shared/-shared \$LDFLAGS/}" \
		scripts/ltconfig || die
}

multilib-native_src_compile_internal() {
	use debug \
		&& myconf="--enable-debug=yes" \
		|| myconf="--enable-debug=no"
	econf ${myconf} || die "econf failed"

	epatch "${FILESDIR}"/sandbox.patch

	emake || die "emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog README* INSTALL NEWS
}

multilib-native_pkg_postinst_internal() {
	ewarn "To allow parallel installation of sigc++-1.0 and sigc++-1.2,"
	ewarn "the header files are now installed in a version specific"
	ewarn "subdirectory.  Be sure to unmerge any libsigc++ versions"
	ewarn "< 1.0.4 that you may have previously installed."
}

# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libsigc++/libsigc++-2.2.7.ebuild,v 1.3 2011/01/19 21:21:29 hwoarang Exp $

EAPI="3"

inherit base eutils gnome.org flag-o-matic multilib-native

DESCRIPTION="Typesafe callback system for standard C++"
HOMEPAGE="http://libsigc.sourceforge.net/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc test"

# Needs mm-common for eautoreconf
multilib-native_src_prepare_internal() {
	# don't waste time building examples
	sed -i 's|^\(SUBDIRS =.*\)examples\(.*\)$|\1\2|' \
		Makefile.am Makefile.in || die "sed examples failed"

	# don't waste time building tests unless USE=test
	if ! use test ; then
		sed -i 's|^\(SUBDIRS =.*\)tests\(.*\)$|\1\2|' \
			Makefile.am Makefile.in || die "sed tests failed"
	fi
}

multilib-native_src_configure_internal() {
	filter-flags -fno-exceptions

	local myconf="$myconf $(use_enable doc documentation)"

	econf ${myconf} || die "econf failed."
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed."
	dodoc AUTHORS ChangeLog README NEWS TODO || die "dodoc failed"

	if use doc ; then
		dohtml -r docs/reference/html/* docs/images/* || die "dohtml failed"
		insinto /usr/share/doc/${PF}
		doins -r examples || die "doins failed"
	fi
}

multilib-native_pkg_postinst_internal() {
	ewarn "To allow parallel installation of sigc++-1.0, sigc++-1.2, and sigc++2.0"
	ewarn "the header files are now installed in a version specific"
	ewarn "subdirectory.  Be sure to unmerge any libsigc++ versions"
	ewarn "< 1.0.4 that you may have previously installed."
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libperl/libperl-5.10.1.ebuild,v 1.11 2010/02/03 00:15:25 hanno Exp $

EAPI="2"

inherit multilib multilib-native

DESCRIPTION="Larry Wall's Practical Extraction and Report Language"
SRC_URI=""
HOMEPAGE="http://www.gentoo.org/"

LICENSE="|| ( Artistic GPL-1 GPL-2 GPL-3 )"
SLOT="1"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE=""

PDEPEND=">=dev-lang/perl-5.10.1[lib32?]"

multilib-native_src_install_internal() {
	# This is empty function is needed because base_src_install does not work
	# without any data
	einfo "Nothing to do"
}

multilib-native_pkg_postinst_internal() {
	if [[ $(readlink "${ROOT}/usr/$(get_libdir )/libperl$(get_libname)" ) == libperl$(get_libname).1 ]] ; then
		einfo "Removing stale symbolic link: ${ROOT}usr/$(get_libdir)/libperl$(get_libname)"
		rm "${ROOT}"/usr/$(get_libdir )/libperl$(get_libname)
	fi
}

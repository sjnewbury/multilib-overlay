# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libperl/libperl-5.10.1.ebuild,v 1.8 2009/11/16 20:19:25 armin76 Exp $

inherit multilib multilib-native

DESCRIPTION="Larry Wall's Practical Extraction and Report Language"
SRC_URI=""
HOMEPAGE="http://www.gentoo.org/"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~ppc ~s390 ~sparc ~x86"
IUSE=""

PDEPEND=">=dev-lang/perl-5.10.1"

pkg_postinst() {
	if [[ $(readlink "${ROOT}/usr/$(get_libdir )/libperl$(get_libname)" ) == libperl$(get_libname).1 ]] ; then
		einfo "Removing stale symbolic link: ${ROOT}usr/$(get_libdir)/libperl$(get_libname)"
		rm "${ROOT}"/usr/$(get_libdir )/libperl$(get_libname)
	fi
}

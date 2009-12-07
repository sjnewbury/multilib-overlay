# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/pth/pth-2.0.7-r1.ebuild,v 1.2 2008/01/15 00:05:10 vapier Exp $

inherit eutils fixheadtails libtool multilib-native

DESCRIPTION="GNU Portable Threads"
HOMEPAGE="http://www.gnu.org/software/pth/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="debug"

DEPEND=""

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.0.5-parallelfix.patch
	epatch "${FILESDIR}"/${PN}-2.0.6-ldflags.patch
	epatch "${FILESDIR}"/${PN}-2.0.6-sigstack.patch

	ht_fix_file aclocal.m4 configure

	elibtoolize
}

multilib-native_src_compile_internal() {
	local conf
	use debug && conf="${conf} --enable-debug"	# have a bug --disable-debug and shared
	econf ${conf} || die
	emake || die
}

multilib-native_src_install_internal() {
	# install is not parallel safe (last checked 2.0.7-r1)
	emake -j1 DESTDIR="${D}" install || die
	dodoc ANNOUNCE AUTHORS ChangeLog NEWS README THANKS USERS
}

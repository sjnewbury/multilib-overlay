# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/libpaper/libpaper-1.1.21.ebuild,v 1.15 2007/11/20 02:59:28 kumba Exp $

inherit eutils libtool multilib-native

MY_P=${P/-/_}
DESCRIPTION="Library for handling paper characteristics"
HOMEPAGE="http://packages.debian.org/unstable/source/libpaper"
SRC_URI="mirror://debian/pool/main/libp/libpaper/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE=""

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/libpaper-1.1.14.8-malloc.patch
	elibtoolize
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README ChangeLog
	dodir /etc
	(paperconf 2>/dev/null || echo a4) > "${D}"/etc/papersize
}

multilib-native_pkg_postinst_internal() {
	elog "run \"paperconfig -p letter\" as root to use letter-pagesizes"
	elog "or paperconf with normal user privileges."
}

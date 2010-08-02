# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/libpaper/libpaper-1.1.24.ebuild,v 1.1 2010/07/31 13:55:51 tgurr Exp $

EAPI="2"

inherit eutils multilib-native

MY_PV=${PV/_p/+nmu}
DESCRIPTION="Library for handling paper characteristics"
HOMEPAGE="http://packages.debian.org/unstable/source/libpaper"
SRC_URI="mirror://debian/pool/main/libp/libpaper/${PN}_${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

S="${WORKDIR}/${PN}-${MY_PV}"

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README ChangeLog debian/changelog || die "dodoc failed"
	dodir /etc
	(paperconf 2>/dev/null || echo a4) > "${D}"/etc/papersize \
		|| die "papersize config failed"
}

multilib-native_pkg_postinst_internal() {
	echo
	elog "run \"paperconf -p letter\" as root to use letter-pagesizes"
	elog "or paperconf with normal user privileges."
	echo
}

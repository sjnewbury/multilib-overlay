# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libnl/libnl-1.0_pre6.ebuild,v 1.8 2008/01/30 08:16:45 pva Exp $

inherit eutils multilib linux-info multilib-native

DESCRIPTION="A library for applications dealing with netlink socket"
HOMEPAGE="http://people.suug.ch/~tgr/libnl/"
SRC_URI="http://dev.gentoo.org/~steev/distfiles/${P}.tar.bz2"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 ~hppa ~ia64 ppc ~ppc64 x86"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"/lib
	sed -i Makefile -e 's:install -o root -g root:install:'
	cd "${S}"/include
	sed -i Makefile -e 's:install -o root -g root:install:g'
	epatch "${FILESDIR}/${PN}-1.0_pre5-include.diff"
	epatch "${FILESDIR}/${PN}-1.0_pre5-__u64_x86_64.patch"
}

ml-native_src_install() {
	make DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" install || die
	insinto /usr/share/pkgconfig/
	doins "${FILESDIR}"/libnl-1.pc
}

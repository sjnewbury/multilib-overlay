# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libnl/libnl-0.5.0.ebuild,v 1.11 2008/01/30 08:16:45 pva Exp $

inherit eutils multilib multilib-native

DESCRIPTION="A library for applications dealing with netlink socket"
HOMEPAGE="http://people.suug.ch/~tgr/libnl/"
SRC_URI="http://people.suug.ch/~tgr/libnl/files/${P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 hppa ppc ~ppc64 x86"
IUSE=""

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-include.diff"
	epatch "${FILESDIR}/${P}-libdir.patch"
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" install || die
}

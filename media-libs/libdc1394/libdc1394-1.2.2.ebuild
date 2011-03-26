# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdc1394/libdc1394-1.2.2.ebuild,v 1.9 2011/03/21 14:23:54 flameeyes Exp $

EAPI="2"

inherit eutils flag-o-matic multilib-native

DESCRIPTION="Library to interface with IEEE 1394 cameras following the IIDC specification"
HOMEPAGE="http://sourceforge.net/projects/libdc1394/"

SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="1"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86"
IUSE=""

RDEPEND="sys-libs/libraw1394[lib32?]
	x11-libs/libSM[lib32?]
	x11-libs/libXv[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/libtool[lib32?]"

multilib-native_src_unpack_internal() {
	unpack ${A}; cd "${S}"
	epatch "${FILESDIR}"/${PN}-disable-raw-capture.patch
}

multilib-native_src_compile_internal() {
	if has_version '>=sys-libs/glibc-2.4' ; then
		append-flags "-DCLK_TCK=CLOCKS_PER_SEC"
	fi

	econf || die
	emake || die
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die
	dodoc NEWS README AUTHORS
}

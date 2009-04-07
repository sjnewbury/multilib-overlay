# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdc1394/libdc1394-1.2.1.ebuild,v 1.3 2007/07/22 09:35:30 dberkholz Exp $

EAPI="1"

inherit eutils flag-o-matic multilib-native

DESCRIPTION="libdc1394 is a library that is intended to provide a high level programming interface for application developers who wish to control IEEE 1394 based cameras that conform to the 1394-based Digital Camera Specification (found at http://www.1394ta.org/)"
HOMEPAGE="http://sourceforge.net/projects/libdc1394/"

SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="1"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86"
IUSE="X"

RDEPEND=">=sys-libs/libraw1394-0.9.0
		X? ( x11-libs/libSM x11-libs/libXv )"
DEPEND="${RDEPEND}
	!=sys-libs/libdc1394-1.0.0
	sys-devel/libtool"

src_unpack() {
	unpack ${A}; cd ${S}
	if ! use X; then
		epatch ${FILESDIR}/${P}-nox11.patch
	fi
}

multilib-native_src_compile_internal() {
	if has_version '>=sys-libs/glibc-2.4' ; then
		append-flags "-DCLK_TCK=CLOCKS_PER_SEC"
	fi

	econf || die
	emake || die
}

multilib-native_src_install_internal() {
	make DESTDIR=${D} install || die
	dodoc NEWS README AUTHORS
}

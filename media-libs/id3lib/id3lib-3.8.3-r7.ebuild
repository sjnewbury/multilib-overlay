# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/id3lib/id3lib-3.8.3-r7.ebuild,v 1.2 2009/07/16 19:18:11 ssuominen Exp $

EAPI=2
inherit eutils autotools multilib-native

MY_P=${P/_}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Id3 library for C/C++"
HOMEPAGE="http://id3lib.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

RESTRICT="test"

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-zlib.patch
	epatch "${FILESDIR}"/${P}-test_io.patch
	epatch "${FILESDIR}"/${P}-autoconf259.patch
	epatch "${FILESDIR}"/${P}-doxyinput.patch
	epatch "${FILESDIR}"/${P}-unicode16.patch
	epatch "${FILESDIR}"/${P}-gcc-4.3.patch

	# Security fix for bug 189610.
	epatch "${FILESDIR}"/${P}-security.patch

	AT_M4DIR="${S}/m4" eautoreconf
}

multilib-native_src_compile_internal() {
	emake || die "emake failed."

	if use doc; then
		cd doc/
		doxygen Doxyfile || die "doxygen failed"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc AUTHORS ChangeLog HISTORY README THANKS TODO

	if use doc; then
		dohtml -r doc
	fi
}

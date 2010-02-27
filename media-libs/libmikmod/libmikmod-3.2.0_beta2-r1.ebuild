# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmikmod/libmikmod-3.2.0_beta2-r1.ebuild,v 1.8 2010/01/31 00:19:20 maekke Exp $

EAPI=2
MY_P=${P/_/-}
inherit autotools eutils multilib-native

DESCRIPTION="A library to play a wide range of module formats"
HOMEPAGE="http://mikmod.raphnet.net/"
SRC_URI="http://mikmod.raphnet.net/files/${MY_P}.tar.gz"

LICENSE="|| ( LGPL-2.1 LGPL-2 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
# Enable OSS by default since ALSA support isn't available, look below
IUSE="+oss"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-64bit.patch \
		"${FILESDIR}"/${P}-autotools.patch \
		"${FILESDIR}"/${P}-info.patch \
		"${FILESDIR}"/${P}-doubleRegister.patch \
		"${FILESDIR}"/${PN}-CVE-2007-6720.patch \
		"${FILESDIR}"/${PN}-CVE-2009-0179.patch
	AT_M4DIR=${S} eautoreconf
}

multilib-native_src_configure_internal() {
	# * af is something called AF/AFlib.h and -lAF, not audiofile in tree
	# * alsa support is for deprecated API and doesn't work
	econf \
		--disable-af \
		--disable-alsa \
		--disable-esd \
		$(use_enable oss)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS NEWS README TODO
	dohtml docs/*.html

	prep_ml_binaries /usr/bin/libmikmod-config
}

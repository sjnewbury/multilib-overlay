# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmikmod/libmikmod-3.2.0_beta2.ebuild,v 1.1 2009/07/23 18:07:55 ssuominen Exp $

EAPI=2
MY_P=${P/_/-}

inherit autotools eutils multilib-native

DESCRIPTION="A library to play a wide range of module formats"
HOMEPAGE="http://mikmod.raphnet.net/"
SRC_URI="http://mikmod.raphnet.net/files/${MY_P}.tar.gz"

LICENSE="|| ( LGPL-2.1 LGPL-2 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="alsa oss"

RDEPEND="media-libs/audiofile[lib32?]
	alsa? ( media-libs/alsa-lib[lib32?] )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-64bit.patch \
		"${FILESDIR}"/${P}-autotools.patch \
		"${FILESDIR}"/${P}-info.patch \
		"${FILESDIR}"/${P}-doubleRegister.patch
	AT_M4DIR=${S} eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--enable-af \
		$(use_enable alsa) \
		--disable-esd \
		$(use_enable oss)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS NEWS README TODO
	dohtml docs/*.html

	prep_ml_binaries /usr/bin/libmikmod-config
}

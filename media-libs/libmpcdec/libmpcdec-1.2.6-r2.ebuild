# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmpcdec/libmpcdec-1.2.6-r2.ebuild,v 1.14 2009/09/23 21:44:34 aballier Exp $

EAPI=2
inherit autotools eutils multilib-native

DESCRIPTION="Musepack SV7 decoder library"
HOMEPAGE="http://www.musepack.net"
SRC_URI="http://files.musepack.net/source/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="!media-sound/musepack-tools"
DEPEND="${RDEPEND}"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-riceitdown.patch \
		"${FILESDIR}"/${P}+libtool22.patch
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--enable-static \
		--enable-shared
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog README
	find "${D}" -name '*.la' -delete
}

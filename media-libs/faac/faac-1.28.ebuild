# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/faac/faac-1.28.ebuild,v 1.5 2009/08/01 16:12:41 jer Exp $

EAPI=2
inherit autotools eutils multilib-native

DESCRIPTION="Free MPEG-4 audio codecs by AudioCoding.com"
HOMEPAGE="http://www.audiocoding.com/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="<media-libs/libmp4v2-1.9.0[lib32?]"
DEPEND="${RDEPEND}
	!<media-libs/faad2-2.0-r3"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-1.26-external-libmp4v2.patch
	eautoreconf
	epunt_cxx
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO docs/libfaac.pdf
	dohtml docs/*
}

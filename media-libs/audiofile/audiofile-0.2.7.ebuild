# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/audiofile/audiofile-0.2.7.ebuild,v 1.9 2010/09/12 20:16:57 klausman Exp $

EAPI=3
inherit autotools eutils multilib-native

DESCRIPTION="An elegant API for accessing audio files"
HOMEPAGE="http://www.68k.org/~michael/audiofile/"
SRC_URI="http://www.68k.org/~michael/${PN}/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ~ia64 ~mips ppc ppc64 ~sh ~sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-largefile.patch

	sed -i \
		-e 's:noinst_PROGRAMS:check_PROGRAMS:' \
		test/Makefile.am || die

	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		--enable-largefile
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc ACKNOWLEDGEMENTS AUTHORS ChangeLog NEWS NOTES README TODO || die

	prep_ml_binaries /usr/bin/audiofile-config
}

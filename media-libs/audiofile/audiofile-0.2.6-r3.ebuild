# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/audiofile/audiofile-0.2.6-r3.ebuild,v 1.12 2007/09/22 04:54:01 tgall Exp $

EAPI="2"

MULTILIB_IN_SOURCE_BUILD="yes"

inherit libtool eutils multilib-native

DESCRIPTION="An elegant API for accessing audio files"
HOMEPAGE="http://www.68k.org/~michael/audiofile/"
SRC_URI="http://www.68k.org/~michael/audiofile/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"/sfcommands
	epatch "${FILESDIR}"/sfconvert-eradicator.patch
	cd "${S}"
	epatch "${FILESDIR}"/${P}-m4.patch
	epatch "${FILESDIR}"/${P}-constantise.patch
	epatch "${FILESDIR}"/${P}-fmod.patch

	### Patch for bug #118600
	epatch "${FILESDIR}"/${PN}-largefile.patch
	elibtoolize
}

multilib-native_src_configure_internal() {
	econf --enable-largefile || die
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die
	dodoc ACKNOWLEDGEMENTS AUTHORS ChangeLog README TODO NEWS NOTES
}

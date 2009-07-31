# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libogg/libogg-1.1.2.ebuild,v 1.15 2006/10/04 17:42:48 grobian Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="the Ogg media file format library"
HOMEPAGE="http://www.xiph.org/ogg/vorbis/index.html"
SRC_URI="http://downloads.xiph.org/releases/ogg/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epunt_cxx
}

ml-native_src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}

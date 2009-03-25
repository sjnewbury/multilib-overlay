# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libogg/libogg-1.1.3-r1.ebuild,v 1.1 2008/04/18 21:16:38 flameeyes Exp $

EAPI="2"

inherit eutils libtool multilib-native

DESCRIPTION="the Ogg media file format library"
HOMEPAGE="http://xiph.org/ogg/"
SRC_URI="http://downloads.xiph.org/releases/ogg/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	elibtoolize
	epunt_cxx
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die "make install failed"

	find "${D}" -name '*.la' -delete
}

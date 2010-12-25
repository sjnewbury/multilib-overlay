# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libogg/libogg-1.2.2.ebuild,v 1.1 2010/12/18 15:40:27 ssuominen Exp $

EAPI=3
inherit eutils libtool multilib-native

DESCRIPTION="the Ogg media file format library"
HOMEPAGE="http://xiph.org/ogg/"
SRC_URI="http://downloads.xiph.org/releases/ogg/${P}.tar.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="static-libs"

RDEPEND=""
DEPEND="app-arch/xz-utils[lib32?]"

multilib-native_src_prepare_internal() {
	elibtoolize
	epunt_cxx
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS CHANGES
	find "${D}" -name '*.la' -exec rm -f '{}' +
}

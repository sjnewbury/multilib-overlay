# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libvorbis/libvorbis-1.3.2.ebuild,v 1.1 2010/11/11 15:49:25 ssuominen Exp $

EAPI=3
inherit autotools multilib-native

DESCRIPTION="The Ogg Vorbis sound file format library"
HOMEPAGE="http://xiph.org/vorbis"
SRC_URI="http://downloads.xiph.org/releases/vorbis/${P}.tar.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="static-libs"

RDEPEND="media-libs/libogg[lib32?]"
DEPEND="${RDEPEND}
	app-arch/xz-utils[lib32?]
	dev-util/pkgconfig[lib32?]"

multilib-native_src_prepare_internal() {
	sed -i \
		-e '/CFLAGS/s:-O20::' \
		-e '/CFLAGS/s:-mcpu=750::' \
		configure.ac || die

	AT_M4DIR="m4" eautoreconf
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

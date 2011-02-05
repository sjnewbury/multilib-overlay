# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libid3tag/libid3tag-0.15.1b-r2.ebuild,v 1.8 2011/01/26 16:14:05 ssuominen Exp $

EAPI=2
inherit eutils multilib multilib-native

DESCRIPTION="The MAD id3tag library"
HOMEPAGE="http://www.underbit.com/products/mad/"
SRC_URI="mirror://sourceforge/mad/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="debug static-libs"

RDEPEND=">=sys-libs/zlib-1.1.3[lib32?]"
DEPEND="${RDEPEND}
	dev-util/gperf"

multilib-native_src_prepare_internal() {
	epunt_cxx #74489
	epatch "${FILESDIR}/${PV}"/*.patch
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable debug debugging)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc CHANGES CREDITS README TODO VERSION

	# This file must be updated with every version update
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${FILESDIR}"/id3tag.pc
	sed -i \
		-e "s:libdir=\${exec_prefix}/lib:libdir=/usr/$(get_libdir):" \
		-e "s:0.15.0b:${PV}:" \
		"${D}"/usr/$(get_libdir)/pkgconfig/id3tag.pc || die

	find "${D}" -name '*.la' -exec rm -f '{}' +
}

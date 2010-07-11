# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.43-r2.ebuild,v 1.12 2010/07/09 10:26:53 ssuominen Exp $

EAPI=3
inherit libtool multilib-native

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha arm ia64 m68k ppc s390 sh sparc"
IUSE=""

RDEPEND="sys-libs/zlib[lib32?]
	!media-libs/libpng:1.2"
DEPEND="${RDEPEND}
	app-arch/xz-utils[lib32?]"

multilib-native_src_prepare_internal() {
	elibtoolize
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die

	prep_ml_binaries $(find "${D}"usr/bin/ -type f $(for i in $(get_install_abis); do echo "-not -name "*-$i""; done)| sed "s!${D}!!g")
}

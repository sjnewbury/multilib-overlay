# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.37.ebuild,v 1.6 2009/06/10 19:05:54 maekke Exp $

EAPI="2"

inherit libtool multilib eutils multilib-native

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/libpng/${P}.tar.lzma"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ~ppc ~ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

RDEPEND="sys-libs/zlib[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
	app-arch/lzma-utils"

ml-native_src_prepare() {
	# So we get sane .so versioning on FreeBSD
	elibtoolize
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES KNOWNBUG README TODO Y2KINFO

	prep_ml_binaries /usr/bin/libpng-config /usr/bin/libpng12-config 
}

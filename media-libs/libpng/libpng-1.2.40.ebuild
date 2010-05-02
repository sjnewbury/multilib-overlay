# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.40.ebuild,v 1.10 2010/01/31 16:11:01 armin76 Exp $

EAPI="2"

inherit libtool multilib-native

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/libpng/${P}.tar.bz2"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

RDEPEND="sys-libs/zlib[lib32?]"
DEPEND="${RDEPEND}"

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	# So we get sane .so versioning on FreeBSD
	elibtoolize
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES KNOWNBUG README TODO Y2KINFO

	prep_ml_binaries /usr/bin/libpng-config /usr/bin/libpng12-config
}

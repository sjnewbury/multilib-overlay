# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.35.ebuild,v 1.8 2009/03/19 14:31:50 armin76 Exp $

EAPI="2"

inherit libtool multilib eutils multilib-native

MY_PV=${PV/_}
DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/libpng/${PN}-${MY_PV}.tar.lzma"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE=""

RDEPEND="sys-libs/zlib[lib32?]"
DEPEND="${RDEPEND}
	app-arch/lzma-utils"

S=${WORKDIR}/${PN}-${MY_PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2.24-pngconf-setjmp.patch

	# So we get sane .so versioning on FreeBSD
	elibtoolize
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die

	dodoc ANNOUNCE CHANGES KNOWNBUG README TODO Y2KINFO
}

multilib-native_pkg_postinst_internal() {
	# the libpng authors really screwed around between 1.2.1 and 1.2.3
	if [[ -f ${ROOT}/usr/$(get_libdir)/libpng.so.3.1.2.1 ]] ; then
		rm -f "${ROOT}"/usr/$(get_libdir)/libpng.so.3.1.2.1
	fi
}

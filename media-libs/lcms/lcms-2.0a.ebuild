# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/lcms/lcms-2.0a.ebuild,v 1.13 2010/09/29 15:20:06 jer Exp $

EAPI=2
inherit libtool multilib-native

DESCRIPTION="A lightweight, speed optimized color management engine"
HOMEPAGE="http://www.littlecms.com/"
SRC_URI="mirror://sourceforge/${PN}/lcms2-${PV}.tar.gz"

LICENSE="MIT"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="jpeg static-libs tiff zlib"

RDEPEND="jpeg? ( virtual/jpeg[lib32?] )
	tiff? ( media-libs/tiff[lib32?] )
	zlib? ( sys-libs/zlib[lib32?] )"
DEPEND="${RDEPEND}"

RESTRICT="test" # Segment maxima GBD test fails randomly

S=${WORKDIR}/${P/a}

multilib-native_src_prepare_internal() {
	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_with jpeg) \
		$(use_with tiff) \
		$(use_with zlib)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die

	insinto /usr/share/lcms2/profiles
	doins testbed/*.icm || die

	dodoc AUTHORS ChangeLog || die

	insinto /usr/share/doc/${PF}/pdf
	doins doc/*.pdf || die

	find "${D}" -name '*.la' -exec rm -f '{}' +
}

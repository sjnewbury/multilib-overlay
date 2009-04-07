# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/xvid/xvid-1.2.1.ebuild,v 1.3 2009/02/11 19:35:19 aballier Exp $

EAPI="2"

MULTILIB_IN_SOURCE_BUILD="yes"

inherit eutils fixheadtails multilib-native

MY_PN="${PN}core"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="XviD, a high performance/quality MPEG-4 video de-/encoding solution"
HOMEPAGE="http://www.xvid.org"
SRC_URI="http://downloads.xvid.org/downloads/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="examples altivec"

NASM=">=dev-lang/nasm-2.04"
DEPEND="x86? ( ${NASM} )
	amd64? ( ${NASM} )
	x86-fbsd? ( ${NASM} )"
RDEPEND=""

#S="${WORKDIR}/${MY_PN}/build/generic"
S="${WORKDIR}/${MY_PN}"

multilib-native_src_configure_internal() {
	cd "${S}"/build/generic
	econf $(use_enable altivec)
}

multilib-native_src_compile_internal() {
	cd "${S}"/build/generic
	emake || die "emake failed."
}

multilib-native_src_install_internal() {
	cd "${S}"/build/generic
	emake DESTDIR="${D}" install || die "emake install failed."

	dodoc "${S}"/../../{AUTHORS,ChangeLog*,README,TODO}

	if [[ ${CHOST} == *-darwin* ]]; then
		local mylib=$(basename $(ls "${D}"/usr/$(get_libdir)/libxvidcore.*.dylib))
		dosym ${mylib} /usr/$(get_libdir)/libxvidcore.dylib
	else
		local mylib=$(basename $(ls "${D}"/usr/$(get_libdir)/libxvidcore.so*))
		dosym ${mylib} /usr/$(get_libdir)/libxvidcore.so
		dosym ${mylib} /usr/$(get_libdir)/${mylib%.?}
	fi

	if use examples; then
		dodoc "${S}"/../../CodingStyle
		insinto /usr/share/${PN}
		doins -r "${S}"/../../examples
	fi
}

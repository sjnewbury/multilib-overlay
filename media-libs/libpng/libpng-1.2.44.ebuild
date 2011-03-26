# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.44.ebuild,v 1.8 2011/02/13 08:52:18 grobian Exp $

# this ebuild is only for the libpng12.so.0 SONAME for ABI compat

EAPI="3"

inherit multilib libtool multilib-native

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

RDEPEND="sys-libs/zlib[lib32?]
	!=media-libs/libpng-1.2*:0"
DEPEND="${RDEPEND}
	app-arch/xz-utils[lib32?]"

multilib-native_pkg_setup_internal() {
	if [[ -e ${EROOT}/usr/$(get_libdir)/libpng12.so.0 ]] ; then
		rm -f "${EROOT}"/usr/$(get_libdir)/libpng12.so.0
	fi
}

multilib-native_src_prepare_internal() {
	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		--disable-static
}

multilib-native_src_compile_internal() {
	emake libpng12.la || die
}

multilib-native_src_install_internal() {
	newlib.so .libs/libpng12.so.0.* libpng12.so.0 || die

	prep_ml_binaries $(find "${D}"usr/bin/ -type f $(for i in $(get_install_abis); do echo "-not -name "*-$i""; done)| sed "s!${D}!!g")
}

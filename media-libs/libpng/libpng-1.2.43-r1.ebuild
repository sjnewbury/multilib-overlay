# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.43-r1.ebuild,v 1.5 2010/05/12 18:39:11 ssuominen Exp $

# this ebuild is only for the libpng12.so.0 SONAME for ABI compat

EAPI=3
inherit multilib libtool multilib-native

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

RDEPEND="sys-libs/zlib[lib32?]
	!<media-libs/libpng-1.2.43-r1"
DEPEND="${RDEPEND}
	app-arch/xz-utils[lib32?]"

multilib-native_pkg_setup_internal() {
	if [[ -e ${ROOT}/usr/$(get_libdir)/libpng12.so.0 ]]; then
		rm -f "${ROOT}"/usr/$(get_libdir)/libpng12.so.0
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

multilib-native_src_install_internal() {
	exeinto /usr/$(get_libdir)
	newexe .libs/libpng12.so.0.43.0 libpng12.so.0 || die

	prep_ml_binaries /usr/bin/libpng-config /usr/bin/libpng12-config
}

# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.5.1.ebuild,v 1.2 2011/02/13 08:52:18 grobian Exp $

EAPI="3"

inherit eutils libtool multilib multilib-native

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"

LICENSE="as-is"
SLOT="0"
KEYWORDS=""
#KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="static-libs"

RDEPEND="sys-libs/zlib[lib32?]"
DEPEND="${RDEPEND}
	app-arch/xz-utils[lib32?]"

multilib-native_src_prepare_internal() {
	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES libpng-manual.txt README TODO

	find "${ED}" -name '*.la' -exec rm -f {} +

	prep_ml_binaries $(find "${D}"usr/bin/ -type f $(for i in $(get_install_abis); do echo "-not -name "*-$i""; done)| sed "s!${D}!!g")
}

multilib-native_pkg_preinst_internal() {
#	has_version ${CATEGORY}/${PN}:1.4 && return 0
	preserve_old_lib /usr/$(get_libdir)/libpng14$(get_libname 0)
}

multilib-native_pkg_postinst_internal() {
#	has_version ${CATEGORY}/${PN}:1.4 && return 0
	preserve_old_lib_notify /usr/$(get_libdir)/libpng14$(get_libname 0)
}

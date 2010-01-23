# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jpeg/jpeg-7-r1.ebuild,v 1.3 2010/01/18 15:35:38 ssuominen Exp $

# this ebuild is only for the libjpeg.so.7 SONAME for ABI compat

EAPI="2"

inherit eutils libtool multilib multilib-native

DESCRIPTION="Library to load, handle and manipulate images in the JPEG format"
HOMEPAGE="http://jpegclub.org/ http://www.ijg.org/"
SRC_URI="http://www.ijg.org/files/${PN}src.v${PV}.tar.gz
	mirror://gentoo/${PN}-6b-patches-2.tar.bz2"

LICENSE="as-is"
SLOT="7"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

DEPEND="!~media-libs/jpeg-7:0"

multilib-native_pkg_setup_internal() {
	if [[ -e ${ROOT}/usr/$(get_libdir)/libjpeg.so.7 ]]; then
		rm -f "${ROOT}"/usr/$(get_libdir)/libjpeg.so.7
	fi
}

multilib-native_src_prepare_internal() {
	epatch "${WORKDIR}"/patch/60_all_jpeg-maxmem-sysconf.patch
	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		--enable-shared \
		--disable-static \
		--enable-maxmem=64
}

multilib-native_src_compile_internal() {
	emake libjpeg.la || die
}

multilib-native_src_install_internal() {
	exeinto /usr/$(get_libdir)
	doexe .libs/libjpeg.so.7 || die
}

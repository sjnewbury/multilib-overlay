# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jpeg-compat/jpeg-compat-6b.ebuild,v 1.1 2009/08/22 12:54:01 ssuominen Exp $

EAPI=2
inherit eutils libtool multilib toolchain-funcs multilib-native

PATCH_VER=1.6

DESCRIPTION="Library to load, handle and manipulate images in the JPEG format (transition package)"
HOMEPAGE="http://www.ijg.org/"
SRC_URI="ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v${PV}.tar.gz
	mirror://gentoo/jpeg-6b-patches-${PATCH_VER}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	sys-devel/libtool
	!<media-libs/jpeg-7"

S=${WORKDIR}/${P/-compat}

multilib-native_src_prepare_internal() {
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/patch
	rm libtool-wrap
	ln -s libtool libtool-wrap
	elibtoolize
}

multilib-native_src_configure_internal() {
	tc-export AR CC RANLIB
	econf \
		--enable-shared \
		--disable-static \
		--enable-maxmem=64
}

multilib-native_src_install_internal() {
	exeinto /usr/$(get_libdir)
	doexe .libs/libjpeg.so.62* || die "doexe failed"
}

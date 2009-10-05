# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jpeg/jpeg-6b-r8.ebuild,v 1.14 2008/08/16 14:46:39 vapier Exp $

EAPI="2"

inherit libtool eutils toolchain-funcs multilib-native

PATCH_VER="1.6"
DESCRIPTION="Library to load, handle and manipulate images in the JPEG format"
HOMEPAGE="http://www.ijg.org/"
SRC_URI="ftp://ftp.uu.net/graphics/jpeg/${PN}src.v${PV}.tar.gz
	mirror://gentoo/${P}-patches-${PATCH_VER}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/libtool-1.5.10-r4"

src_unpack() {
	unpack ${A}
	cd "${S}"
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/patch

	# hrmm. this is supposed to update it.
	# true, the bug is here:
	rm libtool-wrap
	ln -s libtool libtool-wrap
	elibtoolize
}

multilib-native_src_configure_internal() {
	tc-export CC RANLIB AR
	econf \
		--enable-shared \
		--enable-static \
		--enable-maxmem=64 \
		|| die "econf failed"
}

multilib-native_src_compile_internal() {
	emake || die "make failed"
	emake -C "${WORKDIR}"/extra || die "make extra failed"
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "install"
	emake -C "${WORKDIR}"/extra install DESTDIR="${D}" || die "install extra"

	dodoc README install.doc usage.doc wizard.doc change.log \
		libjpeg.doc example.c structure.doc filelist.doc \
		coderules.doc
}

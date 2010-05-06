# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jbigkit/jbigkit-1.6-r1.ebuild,v 1.21 2010/02/28 11:25:02 ssuominen Exp $

inherit eutils multilib toolchain-funcs multilib-native

DESCRIPTION="data compression algorithm for bi-level high-resolution images"
HOMEPAGE="http://www.cl.cam.ac.uk/~mgk25/jbigkit/"
SRC_URI="http://www.cl.cam.ac.uk/~mgk25/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE=""

DEPEND=">=sys-apps/sed-4"
RDEPEND=""

S=${WORKDIR}/${PN}

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-build.patch
	epatch "${FILESDIR}"/${P}-shared-lib.patch
	epatch "${FILESDIR}"/${P}-respect-make.patch
}

multilib-native_src_compile_internal() {
	emake CC=$(tc-getCC) || die "emake failed"
}

src_test() {
	LD_LIBRARY_PATH="${S}"/libjbig make test || die "make test failed"
}

multilib-native_src_install_internal() {
	dobin pbmtools/jbgtopbm pbmtools/pbmtojbg || die "dobin"
	doman pbmtools/jbgtopbm.1 pbmtools/pbmtojbg.1

	insinto /usr/include
	newins libjbig/jbig.h jbig.h || die "doins include"
	dolib libjbig/libjbig{.a,$(get_libname)} || die "dolib"

	dodoc ANNOUNCE CHANGES INSTALL TODO
}

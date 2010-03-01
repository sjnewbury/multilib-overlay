# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jbigkit/jbigkit-2.0.ebuild,v 1.4 2010/02/28 11:54:53 ssuominen Exp $

EAPI=2
inherit eutils multilib toolchain-funcs multilib-native

DESCRIPTION="data compression algorithm for bi-level high-resolution images"
HOMEPAGE="http://www.cl.cam.ac.uk/~mgk25/jbigkit/"
SRC_URI="http://www.cl.cam.ac.uk/~mgk25/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE=""

S=${WORKDIR}/${PN}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-build.patch
}

multilib-native_src_compile_internal() {
	tc-export AR CC RANLIB
	emake || die
}

src_test() {
	LD_LIBRARY_PATH=${S}/libjbig make test || die
}

multilib-native_src_install_internal() {
	dobin pbmtools/jbgtopbm{,85} pbmtools/pbmtojbg{,85} || die
	doman pbmtools/jbgtopbm.1 pbmtools/pbmtojbg.1

	insinto /usr/include
	doins libjbig/*.h || die
	dolib libjbig/libjbig{,85}{.a,$(get_libname)} || die

	dodoc ANNOUNCE CHANGES INSTALL TODO
}

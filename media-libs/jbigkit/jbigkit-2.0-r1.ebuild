# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jbigkit/jbigkit-2.0-r1.ebuild,v 1.10 2010/09/05 13:16:55 armin76 Exp $

EAPI="3"

inherit eutils multilib toolchain-funcs multilib-native

DESCRIPTION="data compression algorithm for bi-level high-resolution images"
HOMEPAGE="http://www.cl.cam.ac.uk/~mgk25/jbigkit/"
SRC_URI="http://www.cl.cam.ac.uk/~mgk25/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

S=${WORKDIR}/${PN}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-r1-build.patch
}

multilib-native_src_compile_internal() {
	tc-export AR CC RANLIB
	emake LIBDIR="${EPREFIX}/usr/$(get_libdir)" || die
}

src_test() {
	LD_LIBRARY_PATH=${S}/libjbig make -j1 test || die
}

multilib-native_src_install_internal() {
	dobin pbmtools/jbgtopbm{,85} pbmtools/pbmtojbg{,85} || die
	doman pbmtools/jbgtopbm.1 pbmtools/pbmtojbg.1

	insinto /usr/include
	doins libjbig/*.h || die
	dolib libjbig/libjbig{,85}{.a,$(get_libname)} || die

	dodoc ANNOUNCE CHANGES TODO libjbig/*.txt
}

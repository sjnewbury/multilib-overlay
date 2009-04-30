# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/glew/glew-1.3.5.ebuild,v 1.10 2007/12/04 15:13:29 fmccor Exp $

EAPI="2"

inherit eutils multilib toolchain-funcs multilib-native

DESCRIPTION="The OpenGL Extension Wrangler Library"
HOMEPAGE="http://glew.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tgz"

LICENSE="BSD GLX SGI-B GPL-2"

IUSE=""
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ia64 ppc ~ppc64 sparc x86 ~x86-fbsd"

RDEPEND="virtual/opengl
	virtual/glu"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${PN}

multilib-native_src_prepare_internal() {
	# Portage will strip binaries if needed
	# If we strip here, static library will have no symbols
	sed -i \
		-e "s/-s\b//g" \
		Makefile || die "sed failed"
}

multilib-native_src_compile_internal() {
	# Add system's CFLAGS
	sed -i "s/OPT = \$(POPT)/OPT = ${CFLAGS}/" Makefile
	emake CC=$(tc-getCC) || die "emake failed"
}

multilib-native_src_install_internal() {
	emake GLEW_DEST="${D}/usr" LIBDIR="${D}/usr/$(get_libdir)" install || die "Install failed!"

	dodoc README.txt ChangeLog
	cd "${S}/doc"
	dohtml *.{html,css,png,jpg} || die "Documentation install failed"
	dodoc *.txt || die "Documentation install failed"
}

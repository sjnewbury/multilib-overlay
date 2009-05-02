# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/glew/glew-1.5.1.ebuild,v 1.3 2009/05/01 15:23:49 ranger Exp $

inherit eutils multilib toolchain-funcs multilib-native

DESCRIPTION="The OpenGL Extension Wrangler Library"
HOMEPAGE="http://glew.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tgz"

LICENSE="BSD GLX SGI-B GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

DEPEND="virtual/opengl
	virtual/glu"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"
	edos2unix config/config.guess Makefile
	sed -i \
		-e 's:-s\b::g' \
		-e '95s:$(CFLAGS):& $(LDFLAGS):' \
		-e '98s:$(CFLAGS):& $(LDFLAGS):' \
		Makefile || die "sed failed"
}

multilib-native_src_compile_internal(){
	emake LD="$(tc-getCC) ${LDFLAGS}" CC="$(tc-getCC)" \
		POPT="${CFLAGS}" M_ARCH="" AR="$(tc-getAR)" \
		|| die "emake failed"
}

multilib-native_src_install_internal() {
	emake GLEW_DEST="${D}/usr" LIBDIR="${D}/usr/$(get_libdir)" \
		M_ARCH="" install || die "emake install failed"

	dodoc README.txt || die
	dohtml doc/*.{html,css,png,jpg} || die
}

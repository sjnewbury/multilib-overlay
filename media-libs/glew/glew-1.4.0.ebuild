# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/glew/glew-1.4.0.ebuild,v 1.6 2008/01/15 18:01:50 armin76 Exp $

EAPI="2"

inherit eutils multilib toolchain-funcs multilib-native

DESCRIPTION="The OpenGL Extension Wrangler Library"
HOMEPAGE="http://glew.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tgz"

LICENSE="BSD GLX SGI-B GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ia64 ppc ~ppc64 sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="virtual/opengl
	virtual/glu"
DEPEND="${RDEPEND}
	sys-apps/sed"

S=${WORKDIR}/${PN}

multilib-native_src_prepare_internal() {
	sed -i -e 's:-s\b::g' Makefile
}

multilib-native_src_compile_internal() {
	emake LD="$(tc-getCC) ${LDFLAGS}" CC="$(tc-getCC)" \
		POPT="${CFLAGS}" M_ARCH="" AR="$(tc-getAR)" \
		|| die "emake failed."
}

multilib-native_src_install_internal() {
	emake GLEW_DEST="${D}/usr" LIBDIR="${D}/usr/$(get_libdir)" \
		M_ARCH="" install || die "emake install failed."

	dodoc README.txt
	dohtml doc/*.{html,css,png,jpg}
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/glew/glew-1.5.7-r1.ebuild,v 1.1 2010/11/13 21:27:19 ssuominen Exp $

EAPI=3
inherit multilib toolchain-funcs multilib-native

DESCRIPTION="The OpenGL Extension Wrangler Library"
HOMEPAGE="http://glew.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tgz"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libXmu[lib32?]
	x11-libs/libXi[lib32?]
	virtual/glu[lib32?]
	virtual/opengl[lib32?]
	x11-libs/libXext[lib32?]
	x11-libs/libX11[lib32?]"
DEPEND="${RDEPEND}"

multilib-native_pkg_setup_internal() {
	myglewopts=(
		AR="$(tc-getAR)"
		STRIP=true
		CC="$(tc-getCC)"
		LD="$(tc-getCC) ${LDFLAGS}"
		M_ARCH=""
		LDFLAGS.EXTRA=""
		POPT="${CFLAGS}"
		)
}

multilib-native_src_prepare_internal() {
	sed -i \
		-e '/INSTALL/s:-s::' \
		-e '/$(CC) $(CFLAGS) -o/s:$(CFLAGS):$(CFLAGS) $(LDFLAGS):' \
		Makefile || die

	# don't do stupid Solaris specific stuff that won't work in Prefix
	cp config/Makefile.linux config/Makefile.solaris || die
}

multilib-native_src_compile_internal(){
	emake "${myglewopts[@]}" || die
}

multilib-native_src_install_internal() {
	emake \
		GLEW_DEST="${ED}/usr" \
		LIBDIR="${ED}/usr/$(get_libdir)" \
		"${myglewopts[@]}" install || die

	dodoc doc/*.txt README.txt TODO.txt || die
	dohtml doc/*.{css,html,jpg,png} || die
}

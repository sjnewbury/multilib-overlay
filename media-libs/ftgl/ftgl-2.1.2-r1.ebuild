# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/ftgl/ftgl-2.1.2-r1.ebuild,v 1.17 2008/03/30 22:58:20 ricmm Exp $

EAPI="2"

WANT_AUTOMAKE=latest
WANT_AUTOCONF=latest
inherit eutils flag-o-matic autotools multilib-native

DESCRIPTION="library to use arbitrary fonts in OpenGL applications"
HOMEPAGE="http://homepages.paradise.net.nz/henryj/code/#FTGL"
SRC_URI="http://opengl.geek.nz/ftgl/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 hppa ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE=""

DEPEND=">=media-libs/freetype-2.0.9[lib32?]
	dev-util/cppunit[lib32?]
	virtual/opengl[lib32?]
	virtual/glut[lib32?]"
RDEPEND="${DEPEND}"

S=${WORKDIR}/FTGL/unix

multilib-native_src_prepare_internal() {
	# Use the correct includedir for pkg-config
	epatch \
		"${FILESDIR}"/${PV}-ftgl.pc.in.patch \
		"${FILESDIR}"/${P}-gcc41.patch
	if ! has_version app-doc/doxygen ; then
		cd FTGL/docs
		tar xzf html.tar.gz || die "unpack html.tar.gz"
		ln -fs ../../docs/html "${S}/docs"
	fi
	sed -i \
		-e "s:\((PACKAGE_NAME)\):\1-${PVR}:g" "${S}"/docs/Makefile \
		|| die "sed failed"
	sed -i \
		-e "s:    \\$:\t\\$:g" "${S}"/src/Makefile \
		|| die "sed failed"

	cd "${S}"
	AT_M4DIR=m4 eautoreconf
}

multilib-native_src_configure_internal() {
	strip-flags # ftgl is sensitive - bug #112820
	econf \
		--enable-shared \
		|| die
}

multilib-native_src_install_internal() {
	einstall || die
	dodoc README.txt
}

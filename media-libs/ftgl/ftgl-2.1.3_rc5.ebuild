# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/ftgl/ftgl-2.1.3_rc5.ebuild,v 1.3 2009/03/09 16:42:06 armin76 Exp $

EAPI="2"

WANT_AUTOMAKE=latest
WANT_AUTOCONF=latest
inherit eutils flag-o-matic autotools multilib-native

MY_PV=${PV/_/-}
MY_PV2=${PV/_/\~}
MY_P=${PN}-${MY_PV}
MY_P2=${PN}-${MY_PV2}

DESCRIPTION="library to use arbitrary fonts in OpenGL applications"
HOMEPAGE="http://ftgl.wiki.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~mips ~ppc ~ppc64 ~sparc x86 ~x86-fbsd"
IUSE=""

DEPEND=">=media-libs/freetype-2.0.9[lib32?]
	virtual/opengl[lib32?]
	virtual/glu[lib32?]
	virtual/glut[lib32?]"

S="${WORKDIR}"/${MY_P2}

src_prepare() {
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gentoo.patch
	AT_M4DIR=m4 eautoreconf
}

multilib-native_src_configure_internal() {
	strip-flags # ftgl is sensitive - bug #112820
	econf
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	rm -rf "${D}"/usr/share/doc/ftgl
	dodoc AUTHORS BUGS ChangeLog INSTALL NEWS README TODO \
		docs/projects_using_ftgl.txt
}

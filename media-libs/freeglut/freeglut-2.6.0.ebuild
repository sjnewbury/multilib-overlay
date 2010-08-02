# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freeglut/freeglut-2.6.0.ebuild,v 1.5 2010/08/02 14:59:02 scarabeus Exp $

EAPI="2"

inherit eutils flag-o-matic libtool autotools multilib-native

DESCRIPTION="A completely OpenSourced alternative to the OpenGL Utility Toolkit (GLUT) library"
HOMEPAGE="http://freeglut.sourceforge.net/"
SRC_URI="mirror://sourceforge/freeglut/${P/_/-}.tar.gz
	mpx? ( http://tisch.sourceforge.net/freeglut-2.6.0-mpx-r6.patch )"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug mpx"

RDEPEND="
	virtual/opengl[lib32?]
	virtual/glu[lib32?]
	>=x11-libs/libXi-1.3[lib32?]
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P/_*/}"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${PV}-GFX_radeon.patch"

	use mpx && epatch "${DISTDIR}/${P}-mpx-r6.patch"

	# Please read the comments in the patch before thinking about dropping it
	# yet again...
	epatch "${FILESDIR}/${PN}-2.4.0-bsd-usb-joystick.patch"

	eautoreconf
	# Needed for sane .so versionning on bsd, please don't drop
	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		--disable-warnings \
		--disable-warnings-as-errors \
		--enable-replace-glut \
		$(use_enable debug)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed"
	dohtml -r doc/*.html doc/*.png || die "dohtml failed"
}

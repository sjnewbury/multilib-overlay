# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freeglut/freeglut-2.4.0-r1.ebuild,v 1.14 2008/11/30 09:34:32 vapier Exp $

EAPI="2"

inherit eutils flag-o-matic libtool multilib-native

DESCRIPTION="A completely OpenSourced alternative to the OpenGL Utility Toolkit (GLUT) library"
HOMEPAGE="http://freeglut.sourceforge.net/"
SRC_URI="mirror://sourceforge/freeglut/${P}.tar.gz"

LICENSE="X11"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="virtual/opengl[lib32?]
	virtual/glu[lib32?]
	!media-libs/glut"
DEPEND="${RDEPEND}"

pkg_setup() {
	# bug #134586
	if [[ ${CFLAGS/march/} = ${CFLAGS} ]]; then
		ewarn "You do not have 'march' set in your CFLAGS."
		ewarn "This is known to cause compilation problems"
		ewarn "in ${P}.  If the compile fails, please set"
		ewarn "'march' to the appropriate architecture."
		epause 5
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fixes bug #97390
	epatch "${FILESDIR}"/${P}-macos.patch

	# #131856
	epatch "${FILESDIR}"/${PN}-gcc42.patch

	# (#140542) fix cursor handling so flightgear works
	epatch "${FILESDIR}"/${PV}-cursor.patch

	# Disable BSD's usb joystick support, see reasons in the patch
	epatch "${FILESDIR}"/${P}-bsd-usb-joystick.patch

	# bug #134586
	replace-flags -O3 -O2

	# fixes compilation in multilib environment
	# maybe, this patch causes the problem on 32ul on ppc64, please don't drop use lib32
	use lib32 && epatch "${FILESDIR}"/${P}-multilib-fix.patch

	# Needed for sane .so versionning on bsd, please don't drop
	elibtoolize
}

ml-native_src_configure() {
	# (#191589) Don't let -Werror get tagged on
	econf --disable-warnings || die "econf failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
	docinto doc
	dohtml -r doc/*.html doc/*.png
}

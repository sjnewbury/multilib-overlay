# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jasper/jasper-1.900.1-r1.ebuild,v 1.11 2008/10/07 08:36:02 phosphan Exp $

EAPI="2"

inherit libtool eutils multilib-native

DESCRIPTION="software-based implementation of the codec specified in the JPEG-2000 Part-1 standard"
HOMEPAGE="http://www.ece.uvic.ca/~mdadams/jasper/"
SRC_URI="http://www.ece.uvic.ca/~mdadams/jasper/software/jasper-${PV}.zip"

LICENSE="JasPer2.0"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="opengl jpeg"

RDEPEND="jpeg? ( media-libs/jpeg )
		opengl? ( virtual/opengl virtual/glut )"
DEPEND="${RDEPEND}
		app-arch/unzip"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-overflow-fix.patch

	elibtoolize
}

src_configure() { :; }

multilib-native_src_compile_internal() {
	econf \
		$(use_enable jpeg libjpeg) \
		$(use_enable opengl) \
		--enable-shared \
		|| die
	emake || die "If you got undefined references to OpenGL related libraries,please try 'eselect opengl set xorg-x11' before emerging. See bug #133609."
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die
	dodoc NEWS README doc/*
}

pkg_postinst() {
	elog
	elog "Be noted that API has been changed, and you need to run"
	elog "revdep-rebuild from gentoolkit to correct deps."
	elog
}

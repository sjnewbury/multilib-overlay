# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jasper/jasper-1.900.1-r3.ebuild,v 1.13 2010/09/16 17:15:07 scarabeus Exp $

EAPI="2"

inherit libtool eutils multilib-native

DESCRIPTION="software-based implementation of the codec specified in the JPEG-2000 Part-1 standard"
HOMEPAGE="http://www.ece.uvic.ca/~mdadams/jasper/"
SRC_URI="http://www.ece.uvic.ca/~mdadams/jasper/software/jasper-${PV}.zip
	mirror://gentoo/${P}-fixes-20081208.patch.bz2"

LICENSE="JasPer2.0"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="opengl jpeg"

RDEPEND="jpeg? ( virtual/jpeg[lib32?] )
		opengl? ( virtual/opengl[lib32?] media-libs/freeglut[lib32?] )"
DEPEND="${RDEPEND}
		app-arch/unzip"

multilib-native_src_prepare_internal() {
	epatch "${WORKDIR}"/${P}-fixes-20081208.patch

	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		$(use_enable jpeg libjpeg) \
		$(use_enable opengl) \
		--enable-shared \
		|| die
}

multilib-native_src_compile_internal() {
	emake || die "If you got undefined references to OpenGL related libraries,please try 'eselect opengl set xorg-x11' before emerging. See bug #133609."
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc NEWS README doc/*
}

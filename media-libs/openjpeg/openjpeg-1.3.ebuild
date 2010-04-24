# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openjpeg/openjpeg-1.3.ebuild,v 1.12 2009/02/27 14:39:20 armin76 Exp $

EAPI="2"

inherit eutils toolchain-funcs multilib multilib-native

DESCRIPTION="An open-source JPEG 2000 codec written in C"
HOMEPAGE="http://www.openjpeg.org/"
SRC_URI="http://www.openjpeg.org/openjpeg_v${PV//./_}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="tools"
DEPEND="tools? ( >=media-libs/tiff-3.8.2[lib32?] )"
RDEPEND=${DEPEND}

S="${WORKDIR}/OpenJPEG_v1_3"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-1.2-Makefile.patch
	cp "${FILESDIR}"/${P}-codec-Makefile "${S}"/codec/Makefile
}

multilib-native_src_compile_internal() {
	emake CC="$(tc-getCC)" AR="$(tc-getAR)" COMPILERFLAGS="${CFLAGS} -std=c99 -fPIC" || die "emake failed"
	if use tools; then
		emake -C codec CC="$(tc-getCC)" || die "emake failed"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" INSTALL_LIBDIR="/usr/$(get_libdir)" install || die "install failed"
	if use tools; then
		emake -C codec DESTDIR="${D}" INSTALL_BINDIR="/usr/bin" install || die "install failed"
	fi
	dodoc ChangeLog
}

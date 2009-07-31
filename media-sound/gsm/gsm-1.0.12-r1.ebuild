# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/gsm/gsm-1.0.12-r1.ebuild,v 1.14 2008/12/22 14:20:05 armin76 Exp $

inherit eutils flag-o-matic multilib toolchain-funcs versionator multilib-native

DESCRIPTION="Lossy speech compression library and tool."
HOMEPAGE="http://kbs.cs.tu-berlin.de/~jutta/toast.html"
SRC_URI="http://www.cs.tu-berlin.de/~jutta/${PN}/${P}.tar.gz"

LICENSE="OSI-Approved"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE=""

S="${WORKDIR}"/${PN}-"$(replace_version_separator 2 '-pl' )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-shared.patch
	epatch "${FILESDIR}"/${P}-memcpy.patch
	epatch "${FILESDIR}"/${P}-64bit.patch
}

ml-native_src_compile() {
	# From upstream Makefile. Define this if your host multiplies
	# floats faster than integers, e.g. on a SPARCstation.
	use sparc && append-flags -DUSE_FLOAT_MUL -DFAST

	emake -j1 CCFLAGS="${CFLAGS} -c -DNeedFunctionPrototypes=1" \
		LD="$(tc-getCC)" AR="$(tc-getAR)" CC="$(tc-getCC)" || die "emake failed."
}

ml-native_src_install() {
	dodir /usr/bin /usr/$(get_libdir) /usr/include/gsm /usr/share/man/man{1,3}

	emake -j1 INSTALL_ROOT="${D}"/usr \
		GSM_INSTALL_LIB="${D}"/usr/$(get_libdir) \
		GSM_INSTALL_INC="${D}"/usr/include/gsm \
		GSM_INSTALL_MAN="${D}"/usr/share/man/man3 \
		TOAST_INSTALL_MAN="${D}"/usr/share/man/man1 \
		install || die "emake install failed."

	dolib lib/libgsm.so*

	dosym ../gsm/gsm.h /usr/include/libgsm/gsm.h

	dodoc ChangeLog* MACHINES MANIFEST README
}

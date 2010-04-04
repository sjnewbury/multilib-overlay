# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/dirac/dirac-1.0.2.ebuild,v 1.8 2009/05/30 09:17:32 ulm Exp $

EAPI="2"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils autotools multilib-native

DESCRIPTION="Open Source video codec"
HOMEPAGE="http://dirac.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="mmx debug doc"

DEPEND="doc? ( app-doc/doxygen
	virtual/latex-base
	media-gfx/graphviz[lib32?]
	|| ( app-text/dvipdfm
		app-text/ptex )
		)"
RDEPEND=""

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${PN}-0.5.2-doc.patch"

	AT_M4DIR="m4" eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		$(use_enable mmx) \
		$(use_enable debug) \
		$(use_enable doc) \
		|| die "econf failed"
}

multilib-native_src_compile_internal() {
	VARTEXFONTS="${T}/fonts" emake || die "emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" \
		htmldir="/usr/share/doc/${PF}/html" \
		latexdir="/usr/share/doc/${PF}/programmers" \
		algodir="/usr/share/doc/${PF}/algorithm" \
		faqdir="/usr/share/doc/${PF}" \
		install || die "emake install failed"

	dodoc README AUTHORS NEWS TODO ChangeLog
}

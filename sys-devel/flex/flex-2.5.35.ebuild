# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/flex/flex-2.5.35.ebuild,v 1.11 2009/03/26 04:27:50 dirtyepic Exp $

EAPI="2"

inherit eutils flag-o-matic multilib-native

#DEB_VER=36
DESCRIPTION="GNU lexical analyser generator"
HOMEPAGE="http://flex.sourceforge.net/"
SRC_URI="mirror://sourceforge/flex/${P}.tar.bz2"
#	mirror://debian/pool/main/f/flex/${PN}_${PV}-${DEB_VER}.diff.gz"

LICENSE="FLEX"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="nls static"

DEPEND="nls? ( sys-devel/gettext[$(get_ml_usedeps)?] )"
RDEPEND=""

ml-native_src_prepare() {
	cd "${S}"
	[[ -n ${DEB_VER} ]] && epatch "${WORKDIR}"/${PN}_${PV}-${DEB_VER}.diff
	epatch "${FILESDIR}"/${PN}-2.5.34-isatty.patch #119598
	epatch "${FILESDIR}"/${PN}-2.5.33-pic.patch
	epatch "${FILESDIR}"/${PN}-2.5.35-gcc44.patch
	sed -i 's:^LDFLAGS:LOADLIBES:' tests/test-pthread/Makefile.in #262989
}

ml-native_src_configure() {
	use static && append-ldflags -static
	econf $(use_enable nls) || die
}

ml-native_src_install() {
	emake install DESTDIR="${D}" || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS ONEWS README* THANKS TODO
	dosym flex /usr/bin/lex
}

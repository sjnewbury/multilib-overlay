# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/flex/flex-2.5.35_p10.ebuild,v 1.1 2010/11/16 20:32:45 flameeyes Exp $

EAPI=2

inherit eutils flag-o-matic autotools multilib-native

if [[ ${PV} == *_p* ]]; then
	DEB_DIFF=${PN}_${PV/_p/-}
fi

MY_P=${P%_p*}

DESCRIPTION="The Fast Lexical Analyzer"
HOMEPAGE="http://flex.sourceforge.net/"
SRC_URI="mirror://sourceforge/flex/${MY_P}.tar.bz2
	${DEB_DIFF:+mirror://debian/pool/main/f/flex/${DEB_DIFF}.diff.gz}"

LICENSE="FLEX"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="nls static"

DEPEND="nls? ( sys-devel/gettext[lib32?] )"
RDEPEND=""

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	[[ -n ${DEB_DIFF} ]] && epatch "${WORKDIR}"/${DEB_DIFF}.diff
	epatch "${FILESDIR}"/${PN}-2.5.35-gcc44.patch
	epatch "${FILESDIR}"/${PN}-2.5.35-saneautotools.patch

	eautoreconf
}

multilib-native_src_configure_internal() {
	use static && append-ldflags -static
	econf $(use_enable nls)
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS ONEWS README* THANKS TODO || die
	dosym flex /usr/bin/lex
}

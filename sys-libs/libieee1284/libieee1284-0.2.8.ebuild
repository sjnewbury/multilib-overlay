# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libieee1284/libieee1284-0.2.8.ebuild,v 1.9 2007/09/18 13:30:16 vapier Exp $

EAPI="2"

inherit autotools eutils multilib-native

DESCRIPTION="Library to query devices using IEEE1284"
HOMEPAGE="http://cyberelk.net/tim/libieee1284/index.html"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2
		 mirror://gentoo/${P}-dbjh-v4.diff.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="doc"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-lang/python[lib32?]
	doc? (
		app-text/docbook-sgml-utils
		>=app-text/docbook-sgml-dtd-4.1
		app-text/docbook-dsssl-stylesheets
		dev-perl/XML-RegExp
	)"

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	epatch "${DISTDIR}/${P}-dbjh-v4.diff.bz2"
	eautoreconf
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS NEWS README* TODO doc/interface*
}

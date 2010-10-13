# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libieee1284/libieee1284-0.2.11-r1.ebuild,v 1.3 2010/10/06 19:52:19 maekke Exp $

EAPI="3"

PYTHON_DEPEND="python? 2"
inherit python multilib-native

DESCRIPTION="Library to query devices using IEEE1284"
HOMEPAGE="http://cyberelk.net/tim/libieee1284/index.html"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86 ~x86-fbsd"
IUSE="doc python"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-lang/python[lib32?]
	doc? (
		app-text/docbook-sgml-utils
		>=app-text/docbook-sgml-dtd-4.1
		app-text/docbook-dsssl-stylesheets
		dev-perl/XML-RegExp
	)"

multilib-native_pkg_setup_internal() {
	python_set_active_version 2
}

multilib-native_src_configure_internal() {
	econf \
		$(use_with python) \
		--disable-dependency-tracking
}

multilib-native_src_install_internal() {
	emake DESTDIR="${ED}" install || die "emake install failed"
	dodoc AUTHORS NEWS README* TODO doc/interface* || die
}

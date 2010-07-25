# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/unixODBC/unixODBC-2.3.0.ebuild,v 1.11 2010/07/20 18:59:53 grobian Exp $

EAPI=3
inherit libtool multilib-native

DESCRIPTION="A complete ODBC driver manager"
HOMEPAGE="http://www.unixodbc.org/"
SRC_URI="mirror://sourceforge/unixodbc/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm ~hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris"
IUSE="+minimal odbcmanual static-libs"

RDEPEND=">=sys-devel/libtool-2.2.6b[lib32?]
	>=sys-libs/readline-6.0_p4[lib32?]
	>=sys-libs/ncurses-5.6-r2[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/flex[lib32?]"

multilib-native_src_prepare_internal() {
	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		--sysconfdir="${EPREFIX}/etc/${PN}" \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable !minimal drivers) \
		$(use_enable !minimal driver-conf)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README || die

	if use prefix; then
		dodoc README* || die
	fi

	if use odbcmanual; then
		dohtml -a css,gif,html,sql,vsd -r doc/* || die
	fi
}

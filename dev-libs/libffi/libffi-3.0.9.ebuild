# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libffi/libffi-3.0.9.ebuild,v 1.3 2010/01/04 23:42:10 maekke Exp $

EAPI=2
inherit libtool multilib-native

DESCRIPTION="a portable, high level programming interface to various calling conventions."
HOMEPAGE="http://sourceware.org/libffi/"
SRC_URI="ftp://sourceware.org/pub/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~mips ~ppc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="debug static-libs test"

RDEPEND=""
DEPEND="test? ( dev-util/dejagnu )"

multilib-native_src_prepare_internal() {
	elibtoolize
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable debug)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog* README
}

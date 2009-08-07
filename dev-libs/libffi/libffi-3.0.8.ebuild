# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libffi/libffi-3.0.8.ebuild,v 1.14 2009/07/22 18:49:00 klausman Exp $

EAPI=2
inherit eutils multilib-native

DESCRIPTION="a portable, high level programming interface to various calling conventions."
HOMEPAGE="http://sourceware.org/libffi"
SRC_URI="ftp://sourceware.org/pub/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ~ia64 ppc ~ppc64 ~s390 ~sh sparc x86"
IUSE="debug static-libs test"

RDEPEND=""
DEPEND="!<dev-libs/g-wrap-1.9.11
	test? ( dev-util/dejagnu )"

ml-native_src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable debug)
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog* README TODO
}

pkg_postinst() {
	ewarn "Please unset USE flag libffi in sys-devel/gcc. There is no"
	ewarn "file collision but your package might link to wrong library."
	ebeep
}

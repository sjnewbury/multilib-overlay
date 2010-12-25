# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libcap-ng/libcap-ng-0.6.2.ebuild,v 1.13 2010/12/18 17:50:47 armin76 Exp $

EAPI="2"

inherit eutils autotools flag-o-matic multilib-native

DESCRIPTION="POSIX 1003.1e capabilities"
HOMEPAGE="http://people.redhat.com/sgrubb/libcap-ng/"
SRC_URI="http://people.redhat.com/sgrubb/libcap-ng/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 arm hppa ~ia64 ppc ppc64 sparc x86"
IUSE="python"

RDEPEND="sys-apps/attr[lib32?]
	python? ( dev-lang/python[lib32?] )"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers
	python? ( dev-lang/swig )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-gentoo.patch
	eautoreconf

	use sparc && replace-flags -O? -O0
}

multilib-native_src_configure_internal() {
	econf $(use_enable python) || die "econf failed"
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "emake install failed"
	dodoc ChangeLog README
}

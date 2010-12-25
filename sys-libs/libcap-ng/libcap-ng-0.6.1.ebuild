# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libcap-ng/libcap-ng-0.6.1.ebuild,v 1.5 2010/12/18 17:50:47 armin76 Exp $

EAPI="2"

inherit eutils autotools multilib-native

DESCRIPTION="POSIX 1003.1e capabilities"
HOMEPAGE="http://people.redhat.com/sgrubb/libcap-ng/"
SRC_URI="http://people.redhat.com/sgrubb/libcap-ng/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~x86"
IUSE="python"

COMMON_DEPEND="sys-apps/attr[lib32?]"
RDEPEND="${COMMON_DEPEND}
	python? ( dev-lang/python[lib32?] )"
DEPEND="${COMMON_DEPEND}
	sys-kernel/linux-headers
	python? ( dev-lang/swig dev-lang/python[lib32?] )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-gentoo.patch
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf $(use_enable python) || die "econf failed"
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "emake install failed"

	dodoc ChangeLog README
}

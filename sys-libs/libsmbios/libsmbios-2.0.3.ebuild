# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libsmbios/libsmbios-2.0.3.ebuild,v 1.2 2009/04/11 16:46:12 loki_val Exp $

EAPI=2

inherit eutils multilib-native

DESCRIPTION="Provide access to (SM)BIOS information"
HOMEPAGE="http://linux.dell.com/libsmbios/main/index.html"
SRC_URI="http://linux.dell.com/libsmbios/download/libsmbios/${P}/${P}.tar.gz"

LICENSE="GPL-2 OSL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="test"

DEPEND="dev-libs/libxml2[lib32?]
	sys-libs/zlib[lib32?]
	test? ( dev-util/cppunit )"
RDEPEND=${DEPEND}

RESTRICT=test

ml-native_src_prepare() {
	epatch "${FILESDIR}/libsmbios-2.0.3-gcc44.patch"
}

ml-native_src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
	insinto /usr/include/
	doins -r include/smbios/

	dodoc AUTHORS ChangeLog NEWS README TODO
}

pkg_postinst() {
	ewarn "If you upgrade from a version of libsmbios older than 2.0.2,"
	ewarn "you should run revdep-rebuild."
}

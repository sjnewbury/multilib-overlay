# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libsmbios/libsmbios-0.13.10.ebuild,v 1.1 2007/09/04 20:16:01 cedk Exp $

EAPI="2"

inherit multilib-native

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

src_test() {
	einfo "testing currently broken - bypassing"
}

ml-native_src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
	insinto /usr/include/
	doins -r include/smbios/

	dodoc AUTHORS ChangeLog NEWS README TODO
}

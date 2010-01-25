# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/c-ares/c-ares-1.6.0.ebuild,v 1.1 2009/01/18 18:02:36 pva Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="C library that resolves names asynchronously"
HOMEPAGE="http://daniel.haxx.se/projects/c-ares/"
SRC_URI="http://daniel.haxx.se/projects/c-ares/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

DEPEND=""
RDEPEND=""

multilib-native_src_configure_internal() {
	econf --enable-shared
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc RELEASE-NOTES CHANGES NEWS README*
	prep_ml_includes
}

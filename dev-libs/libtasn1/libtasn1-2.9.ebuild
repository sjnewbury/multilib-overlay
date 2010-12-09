# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libtasn1/libtasn1-2.9.ebuild,v 1.1 2010/12/07 08:13:13 arfrever Exp $

EAPI="3"

inherit multilib-native

DESCRIPTION="ASN.1 library"
HOMEPAGE="http://www.gnu.org/software/libtasn1/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-3 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="doc"

DEPEND=">=dev-lang/perl-5.6[lib32?]
	sys-devel/bison"
RDEPEND=""

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS || die "dodoc failed"

	if use doc; then
		dodoc doc/libtasn1.ps || die "dodoc failed"
	fi
}

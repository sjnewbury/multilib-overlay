# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libksba/libksba-1.0.7.ebuild,v 1.7 2010/01/14 21:30:52 fauli Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="makes X.509 certificates and CMS easily accessible to applications"
HOMEPAGE="http://www.gnupg.org/related_software/libksba"
#SRC_URI="ftp://ftp.gnupg.org/gcrypt/${PN}/${P}.tar.bz2"
SRC_URI="mirror://gnupg/libksba/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x64-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-libs/libgpg-error-1.4[lib32?]"
RDEPEND="${DEPEND}"

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO VERSION
}

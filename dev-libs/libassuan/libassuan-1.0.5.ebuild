# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libassuan/libassuan-1.0.5.ebuild,v 1.6 2011/01/12 16:07:18 flameeyes Exp $

EAPI="2"

inherit flag-o-matic eutils multilib-native

DESCRIPTION="Standalone IPC library used by gpg, gpgme and newpg"
HOMEPAGE="http://www.gnupg.org/related_software/libassuan/index.en.html"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

DEPEND=">=dev-libs/pth-1.3.7[lib32?]
	>=dev-libs/libgpg-error-1.4[lib32?]"
RDEPEND="${DEPEND}"

multilib-native_src_prepare_internal()
{
	epatch "${FILESDIR}"/libassuan-1.0.5-qa.patch
}

multilib-native_src_configure_internal() {
	# https://bugs.g10code.com/gnupg/issue817
	append-flags "-fpic -fPIC"
	append-ldflags "-fpic -fPIC"

	econf || die
}

multilib-native_src_install_internal() {
	make install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}

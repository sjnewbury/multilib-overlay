# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libssh2/libssh2-0.18.ebuild,v 1.15 2009/06/26 11:25:30 pva Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="Library implementing the SSH2 protocol"
HOMEPAGE="http://www.libssh2.org/"
SRC_URI="mirror://sourceforge/libssh2/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="gcrypt"

DEPEND="!gcrypt? ( dev-libs/openssl[lib32?] )
	gcrypt? ( dev-libs/libgcrypt[lib32?] )
	sys-libs/zlib[lib32?]"
RDEPEND=${DEPEND}

multilib-native_src_configure_internal() {
	econf $(use_enable gcrypt libgcrypt)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libssh2/libssh2-1.2.6.ebuild,v 1.2 2010/10/02 20:39:29 grobian Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Library implementing the SSH2 protocol"
HOMEPAGE="http://www.libssh2.org/"
SRC_URI="http://www.${PN}.org/download/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x64-macos ~x86-solaris"
IUSE="gcrypt zlib"

DEPEND="!gcrypt? ( dev-libs/openssl[lib32?] )
	gcrypt? ( dev-libs/libgcrypt[lib32?] )
	zlib? ( sys-libs/zlib[lib32?] )"
RDEPEND="${DEPEND}"

multilib-native_src_configure_internal() {
	local myconf

	if use gcrypt; then
		myconf="--with-libgcrypt"
	else
		myconf="--with-openssl"
	fi

	econf \
		$(use_with zlib libz) \
		${myconf}
}

src_test() {
	if [[ ${EUID} -ne 0 ]]; then #286741
		ewarn "Some tests require real user that is allowed to login."
		ewarn "ssh2.sh test disabled."
		sed -e 's:ssh2.sh::' -i tests/Makefile
	fi
	emake check || die
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README
}

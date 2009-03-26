# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgcrypt/libgcrypt-1.4.4.ebuild,v 1.8 2009/03/25 03:35:39 josejx Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="general purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/libgcrypt/${P}.tar.bz2
	ftp://ftp.gnupg.org/gcrypt/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=dev-libs/libgpg-error-1.5[lib32?]"
DEPEND="${RDEPEND}"

multilib-native_src_configure_internal() {
	# --disable-padlock-support for bug #201917
	
	local myconf
	if use lib32 && [[ "${ABI}" == "x86" ]]; then
		myconf="--program-suffix=32"
	fi
	
	econf \
		--disable-padlock-support \
		--disable-dependency-tracking \
		--with-pic \
		--enable-noexecstack \
		${myconf}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README* THANKS TODO
}

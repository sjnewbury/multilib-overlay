# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgcrypt/libgcrypt-1.4.6.ebuild,v 1.11 2011/01/21 02:12:03 robbat2 Exp $

EAPI="3"

inherit autotools eutils multilib-native

DESCRIPTION="General purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/libgcrypt/${P}.tar.bz2
	ftp://ftp.gnupg.org/gcrypt/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="+static-libs"

RDEPEND=">=dev-libs/libgpg-error-1.5[lib32?]"
DEPEND="${RDEPEND}"

multilib-native_src_prepare_internal() {
	# Fix build failure with non-bash /bin/sh.
	eautoreconf

	epunt_cxx
}

multilib-native_src_configure_internal() {
	# --disable-padlock-support for bug #201917
	econf \
		--disable-padlock-support \
		--disable-dependency-tracking \
		--with-pic \
		--enable-noexecstack \
		$(use_enable static-libs static)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README* THANKS TODO || die "dodoc failed"

	prep_ml_binaries /usr/bin/libgcrypt-config
}

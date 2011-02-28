# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgcrypt/libgcrypt-1.5.0_beta1.ebuild,v 1.1 2011/02/23 16:09:48 arfrever Exp $

EAPI="3"

inherit multilib-native

DESCRIPTION="General purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
#SRC_URI="mirror://gnupg/libgcrypt/${P}.tar.bz2
#	ftp://ftp.gnupg.org/gcrypt/${PN}/${P}.tar.bz2"
SRC_URI="ftp://ftp.gnupg.org/gcrypt/alpha/${PN}/${P/_/-}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="static-libs"

RDEPEND=">=dev-libs/libgpg-error-1.8[lib32?]"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P/_/-}"

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

# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgpg-error/libgpg-error-1.6.ebuild,v 1.8 2008/12/07 12:05:54 vapier Exp $

EAPI="2"

inherit libtool eutils multilib-native

DESCRIPTION="Contains error handling functions used by GnuPG software"
HOMEPAGE="http://www.gnupg.org/related_software/libgpg-error"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	#Make the gpg-error-config script cross-compile friendly
	sed -i -e 's|@libdir@|/usr/lib|g' src/gpg-error-config.in 
	# for BSD?
	elibtoolize
}

ml-native_src_configure() {
	econf $(use_enable nls) || die
}

ml-native_src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README

	prep_ml_binaries /usr/bin/gpg-error-config 
}

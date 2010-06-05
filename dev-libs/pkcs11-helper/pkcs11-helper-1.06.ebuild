# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/pkcs11-helper/pkcs11-helper-1.06.ebuild,v 1.6 2009/04/22 21:15:10 maekke Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="PKCS#11 helper library"
HOMEPAGE="http://www.opensc-project.org/pkcs11-helper"
SRC_URI="http://www.opensc-project.org/files/${PN}/${P}.tar.bz2"

LICENSE="|| ( BSD GPL-2 )"
SLOT="0"
KEYWORDS="alpha amd64 arm ~hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="doc gnutls nss"
RESTRICT="test"

RDEPEND=">=dev-libs/openssl-0.9.7[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	doc? ( >=app-doc/doxygen-1.4.7 )
	gnutls? ( >=net-libs/gnutls-1.4.4[lib32?] )
	nss? ( dev-libs/nss[lib32?] )"

multilib-native_src_configure_internal() {
	econf \
		--docdir="/usr/share/doc/${PF}" \
		$(use_enable doc) \
		$(use_enable gnutls crypto-engine-gnutls) \
		$(use_enable nss crypto-engine-nss) \
		|| die
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die
	mv "${D}/usr/share/doc/${PF}/api" "${T}"
	prepalldocs
	mv "${T}/api" "${D}/usr/share/doc/${PF}"
}

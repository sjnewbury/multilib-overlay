# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/opensc/opensc-0.11.13.ebuild,v 1.6 2010/05/20 01:50:41 jer Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="SmartCard library and applications"
HOMEPAGE="http://www.opensc-project.org/opensc/"

SRC_URI="http://www.opensc-project.org/files/${PN}/${P}.tar.gz"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ppc ppc64 s390 sh sparc x86"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="doc openct pcsc-lite"

RDEPEND="dev-libs/openssl[lib32?]
	sys-libs/zlib[lib32?]
	openct? ( >=dev-libs/openct-0.5.0[lib32?] )
	pcsc-lite? ( >=sys-apps/pcsc-lite-1.3.0 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

multilib-native_src_configure_internal() {
	econf \
		--docdir="/usr/share/doc/${PF}" \
		--htmldir="/usr/share/doc/${PF}/html" \
		$(use_enable doc) \
		$(use_enable openct) \
		$(use_enable pcsc-lite pcsc) \
		--with-pinentry="/usr/bin/pinentry"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

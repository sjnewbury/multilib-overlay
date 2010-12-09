# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/opensc/opensc-0.11.13-r1.ebuild,v 1.1 2010/11/29 13:43:03 flameeyes Exp $

EAPI="2"

inherit eutils autotools multilib-native

DESCRIPTION="SmartCard library and applications"
HOMEPAGE="http://www.opensc-project.org/opensc/"

SRC_URI="http://www.opensc-project.org/files/${PN}/${P}.tar.gz"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="doc openct pcsc-lite readline ssl zlib"

# libtool is required at runtime for libltdl
RDEPEND="
	sys-devel/libtool[lib32?]
	zlib? ( sys-libs/zlib[lib32?] )
	readline? ( sys-libs/readline[lib32?] )
	ssl? ( dev-libs/openssl[lib32?] )
	openct? ( >=dev-libs/openct-0.5.0[lib32?] )
	pcsc-lite? ( >=sys-apps/pcsc-lite-1.3.0 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

multilib-native_pkg_setup_internal() {
	if use openct; then
		elog "Support for openct is deprecated."
		elog "It is recommended to use pcsc-lite."
	fi
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}+pcsc-lite-1.6.2.patch

	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--docdir="/usr/share/doc/${PF}" \
		--htmldir="/usr/share/doc/${PF}/html" \
		$(use_enable doc) \
		$(use_enable openct) \
		$(use_enable pcsc-lite pcsc) \
		$(use_enable readline) \
		$(use_enable ssl openssl) \
		$(use_enable zlib) \
		--with-pinentry="/usr/bin/pinentry"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

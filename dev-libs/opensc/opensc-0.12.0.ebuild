# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/opensc/opensc-0.12.0.ebuild,v 1.1 2011/03/14 00:33:33 kingtaco Exp $

EAPI="2"

inherit eutils autotools multilib-native

DESCRIPTION="SmartCard library and applications"
HOMEPAGE="http://www.opensc-project.org/opensc/"

SRC_URI="http://www.opensc-project.org/files/${PN}/${P}.tar.gz"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="doc pcsc-lite readline ssl zlib"

# libtool is required at runtime for libltdl
RDEPEND="
	sys-devel/libtool[lib32?]
	zlib? ( sys-libs/zlib[lib32?] )
	readline? ( sys-libs/readline[lib32?] )
	ssl? ( dev-libs/openssl[lib32?] )
	pcsc-lite? ( >=sys-apps/pcsc-lite-1.3.0 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

multilib-native_src_prepare_internal() {
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--docdir="/usr/share/doc/${PF}" \
		--htmldir="/usr/share/doc/${PF}/html" \
		$(use_enable doc) \
		$(use_enable pcsc-lite pcsc) \
		$(use_enable readline) \
		$(use_enable ssl openssl) \
		$(use_enable zlib) \
		--with-pinentry="/usr/bin/pinentry"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

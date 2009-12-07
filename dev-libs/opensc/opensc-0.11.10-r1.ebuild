# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/opensc/opensc-0.11.10-r1.ebuild,v 1.1 2009/10/24 11:08:52 flameeyes Exp $

EAPI="2"

inherit multilib multilib-native

DESCRIPTION="SmartCard library and applications"
HOMEPAGE="http://www.opensc-project.org/opensc/"

SRC_URI="http://www.opensc-project.org/files/${PN}/${P}.tar.gz"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="doc nsplugin openct pcsc-lite"

RDEPEND="dev-libs/openssl[lib32?]
	sys-libs/zlib[lib32?]
	nsplugin? (
		app-crypt/pinentry
		x11-libs/libXt[lib32?]
	)
	openct? ( >=dev-libs/openct-0.5.0[lib32?] )
	pcsc-lite? ( >=sys-apps/pcsc-lite-1.3.0[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	nsplugin? ( dev-libs/libassuan[lib32?] )"

multilib-native_src_configure_internal() {
	econf \
		--docdir="/usr/share/doc/${PF}" \
		--htmldir="/usr/share/doc/${PF}/html" \
		$(use_enable openct) \
		$(use_enable pcsc-lite pcsc) \
		$(use_enable nsplugin) \
		$(use_enable doc) \
		--with-plugindir=/usr/$(get_libdir)/nsbrowser/plugins \
		--with-pinentry="/usr/bin/pinentry"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/startup-notification/startup-notification-0.10.ebuild,v 1.11 2010/01/15 22:10:10 fauli Exp $

EAPI="2"
WANT_AUTOMAKE="1.10"

inherit autotools multilib-native

DESCRIPTION="Application startup notification and feedback library"
HOMEPAGE="http://www.freedesktop.org/software/startup-notification"
SRC_URI="http://freedesktop.org/software/${PN}/releases/${P}.tar.gz"

LICENSE="LGPL-2 BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libSM[lib32?]
	x11-libs/libICE[lib32?]
	x11-libs/libxcb[lib32?]
	>=x11-libs/xcb-util-0.3[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	x11-proto/xproto
	x11-libs/libXt[lib32?]"

multilib-native_src_prepare_internal() {
	# Do not build tests unless required
	epatch "${FILESDIR}/${P}-tests.patch"

	eautomake
}

multilib-native_src_configure_internal() {
	econf --disable-static
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README doc/startup-notification.txt || die "dodoc failed"
}

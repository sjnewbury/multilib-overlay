# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/startup-notification/startup-notification-0.9.ebuild,v 1.11 2011/02/06 10:47:12 leio Exp $

EAPI="2"

inherit gnome.org multilib-native

DESCRIPTION="Application startup notification and feedback library"
HOMEPAGE="http://www.freedesktop.org/software/startup-notification"

LICENSE="LGPL-2 BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libSM[lib32?]
	x11-libs/libICE[lib32?]"
DEPEND="${RDEPEND}
	x11-proto/xproto
	x11-libs/libXt[lib32?]"

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README doc/startup-notification.txt
}

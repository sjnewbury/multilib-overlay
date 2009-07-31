# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/startup-notification/startup-notification-0.9.ebuild,v 1.10 2007/09/22 05:00:32 tgall Exp $

EAPI="2"

inherit gnome.org multilib-native

DESCRIPTION="Application startup notification and feedback library"
HOMEPAGE="http://www.freedesktop.org/software/startup-notification"

LICENSE="LGPL-2 BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="x11-libs/libX11[$(get_ml_usedeps)?]
	x11-libs/libSM[$(get_ml_usedeps)?]
	x11-libs/libICE[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
	x11-proto/xproto
	x11-libs/libXt[$(get_ml_usedeps)?]"

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README doc/startup-notification.txt
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/startup-notification/startup-notification-0.10.ebuild,v 1.1 2009/04/25 03:19:03 dang Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Application startup notification and feedback library"
HOMEPAGE="http://www.freedesktop.org/software/startup-notification"
SRC_URI="http://freedesktop.org/software/${PN}/releases/${P}.tar.gz"

LICENSE="LGPL-2 BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="x11-libs/libX11[$(get_ml_usedeps)?]
	x11-libs/libSM[$(get_ml_usedeps)?]
	x11-libs/libICE[$(get_ml_usedeps)?]
	x11-libs/libxcb[$(get_ml_usedeps)?]
	>=x11-libs/xcb-util-0.3[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)?]
	x11-proto/xproto
	x11-libs/libXt[$(get_ml_usedeps)?]"

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README doc/startup-notification.txt
}

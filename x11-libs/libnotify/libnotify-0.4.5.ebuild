# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libnotify/libnotify-0.4.5.ebuild,v 1.9 2009/04/05 14:11:42 klausman Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="Notifications library"
HOMEPAGE="http://www.galago-project.org/"
SRC_URI="http://www.galago-project.org/files/releases/source/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ~hppa ~ia64 ppc ppc64 ~sh ~sparc x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=x11-libs/gtk+-2.6[$(get_ml_usedeps)?]
		>=dev-libs/glib-2.6[$(get_ml_usedeps)?]
		>=dev-libs/dbus-glib-0.76[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
		doc? ( >=dev-util/gtk-doc-1.4 )"
PDEPEND="|| ( x11-misc/notification-daemon[$(get_ml_usedeps)?]
		x11-misc/notification-daemon-xfce[$(get_ml_usedeps)?]
		x11-misc/xfce4-notifyd[$(get_ml_usedeps)?] )"

ml-native_src_install() {
	emake install DESTDIR="${D}" || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS
}

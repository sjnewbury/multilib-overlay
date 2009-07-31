# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/notification-daemon/notification-daemon-0.3.7.ebuild,v 1.11 2007/08/25 13:59:29 vapier Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

DESCRIPTION="Notifications daemon"
HOMEPAGE="http://www.galago-project.org/"
SRC_URI="http://www.galago-project.org/files/releases/source/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=dev-libs/glib-2.4.0[$(get_ml_usedeps)]
		 >=x11-libs/gtk+-2.4.0[$(get_ml_usedeps)]
		 >=gnome-base/gconf-2.4.0[$(get_ml_usedeps)]
		 >=x11-libs/libsexy-0.1.3[$(get_ml_usedeps)]
		 >=dev-libs/dbus-glib-0.71[$(get_ml_usedeps)]
		 x11-libs/libwnck[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
		=sys-devel/automake-1.9*
		>=sys-devel/gettext-0.14[$(get_ml_usedeps)]
		!xfce-extra/notification-daemon-xfce"

DOCS="AUTHORS ChangeLog NEWS"

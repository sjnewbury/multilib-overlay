# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-xfce/gtk-engines-xfce-2.8.0.ebuild,v 1.4 2011/01/25 20:32:12 jer Exp $

EAPI=3
MY_PN=gtk-xfce-engine
inherit xfconf multilib-native

DESCRIPTION="Xfce's GTK+ engine and themes"
HOMEPAGE="http://www.xfce.org/projects/"
SRC_URI="mirror://xfce/src/xfce/${MY_PN}/2.8/${MY_PN}-${PV}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~mips ppc ppc64 ~sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug"

RDEPEND=">=dev-libs/glib-2.18:2[lib32?]
	>=x11-libs/gtk+-2.14:2[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

S=${WORKDIR}/${MY_PN}-${PV}

multilib-native_pkg_setup_internal() {
	XFCONF=(
		--disable-dependency-tracking
		$(xfconf_use_debug)
		)

	DOCS="AUTHORS ChangeLog NEWS README"
}

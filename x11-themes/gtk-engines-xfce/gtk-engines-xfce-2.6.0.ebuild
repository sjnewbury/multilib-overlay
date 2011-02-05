# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-xfce/gtk-engines-xfce-2.6.0.ebuild,v 1.13 2011/02/04 18:02:46 ssuominen Exp $

EAPI=3
MY_PN=gtk-xfce-engine
inherit xfconf multilib-native

DESCRIPTION="GTK+ Xfce4 theme engine"
HOMEPAGE="http://www.xfce.org/"
SRC_URI="mirror://xfce/src/xfce/${MY_PN}/2.6/${MY_PN}-${PV}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.12:2[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

S=${WORKDIR}/${MY_PN}-${PV}

multilib-native_pkg_setup_internal() {
	DOCS="AUTHORS ChangeLog NEWS README"
	XFCONF=(
		--disable-dependency-tracking
		)
}

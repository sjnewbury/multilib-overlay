# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libbonobo/libbonobo-2.24.0.ebuild,v 1.6 2008/12/17 14:32:55 ranger Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="GNOME CORBA framework"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2.1 GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ~mips ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE="debug doc"

RDEPEND=">=dev-libs/glib-2.8[$(get_ml_usedeps)?]
	>=gnome-base/orbit-2.14.0[$(get_ml_usedeps)?]
	>=dev-libs/libxml2-2.4.20[$(get_ml_usedeps)?]
	>=sys-apps/dbus-1.0.0[$(get_ml_usedeps)?]
	>=dev-libs/dbus-glib-0.74[$(get_ml_usedeps)?]
	>=dev-libs/popt-1.5[$(get_ml_usedeps)?]
	!gnome-base/bonobo-activation"
DEPEND="${RDEPEND}
	sys-devel/flex
	x11-apps/xrdb
	>=dev-util/pkgconfig-0.9[$(get_ml_usedeps)?]
	>=dev-util/intltool-0.35
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF} $(use_enable debug bonobo-activation-debug)"
}

src_unpack() {
	gnome2_src_unpack

	sed -i -e '/DISABLE_DEPRECATED/d' \
		"${S}/activation-server/Makefile.am" "${S}/activation-server/Makefile.in" \
		"${S}/bonobo/Makefile.am" "${S}/bonobo/Makefile.in" \
		"${S}/bonobo-activation/Makefile.am" "${S}/bonobo-activation/Makefile.in"

	sed -i -e 's:-DG_DISABLE_DEPRECATED ::g' \
		"${S}/tests/test-activation/Makefile.am" "${S}/tests/test-activation/Makefile.in"
}

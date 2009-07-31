# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libbonoboui/libbonoboui-2.24.1.ebuild,v 1.4 2009/04/19 15:44:13 maekke Exp $

GCONF_DEBUG="no"

EAPI="2"

inherit eutils virtualx gnome2 multilib-native

DESCRIPTION="User Interface part of libbonobo"
HOMEPAGE="http://developer.gnome.org/arch/gnome/componentmodel/bonobo.html"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ~hppa ~ia64 ~mips ppc ppc64 ~sh ~sparc x86 ~x86-fbsd"
IUSE="doc"

# GTK+ dep due to bug #126565
RDEPEND=">=gnome-base/libgnomecanvas-1.116[$(get_ml_usedeps)?]
	>=gnome-base/libbonobo-2.22[$(get_ml_usedeps)?]
	>=gnome-base/libgnome-2.13.7[$(get_ml_usedeps)?]
	>=dev-libs/libxml2-2.4.20[$(get_ml_usedeps)?]
	>=gnome-base/gconf-2[$(get_ml_usedeps)?]
	>=x11-libs/gtk+-2.8.12[$(get_ml_usedeps)?]
	>=dev-libs/glib-2.6.0[$(get_ml_usedeps)?]
	>=gnome-base/libglade-1.99.11[$(get_ml_usedeps)?]
	>=dev-libs/popt-1.5[$(get_ml_usedeps)?]"

DEPEND="${RDEPEND}
	x11-apps/xrdb
	sys-devel/gettext
	>=dev-util/pkgconfig-0.20[$(get_ml_usedeps)?]
	>=dev-util/intltool-0.40
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"

ml-native_src_compile() {
	addpredict "/root/.gnome2_private"

	gnome2_src_compile
}

src_test() {
	addwrite "/root/.gnome2_private"
	Xemake check || die "tests failed"
}

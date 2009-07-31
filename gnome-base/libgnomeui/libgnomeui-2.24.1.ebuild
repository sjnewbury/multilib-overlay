# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnomeui/libgnomeui-2.24.1.ebuild,v 1.4 2009/04/23 17:45:34 klausman Exp $

GCONF_DEBUG="no"

EAPI="2"

inherit eutils gnome2 multilib-native

DESCRIPTION="User Interface routines for Gnome"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ~hppa ~ia64 ~mips ppc ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc"

# gtk+-2.14 dep instead of 2.12 ensures system doesn't loose VFS capabilities in GtkFilechooser
RDEPEND=">=dev-libs/libxml2-2.4.20[$(get_ml_usedeps)?]
	>=gnome-base/libgnome-2.13.7[$(get_ml_usedeps)?]
	>=gnome-base/libgnomecanvas-2[$(get_ml_usedeps)?]
	>=gnome-base/libbonoboui-2.13.1[$(get_ml_usedeps)?]
	>=gnome-base/gconf-2[$(get_ml_usedeps)?]
	>=x11-libs/pango-1.1.2[$(get_ml_usedeps)?]
	>=dev-libs/glib-2.16[$(get_ml_usedeps)?]
	>=x11-libs/gtk+-2.14[$(get_ml_usedeps)?]
	>=gnome-base/gnome-vfs-2.7.3[$(get_ml_usedeps)?]
	>=gnome-base/libglade-2[$(get_ml_usedeps)?]
	>=gnome-base/gnome-keyring-0.4[$(get_ml_usedeps)?]
	>=dev-libs/popt-1.5[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9[$(get_ml_usedeps)?]
	>=dev-util/intltool-0.40
	doc? ( >=dev-util/gtk-doc-1 )"

PDEPEND="x11-themes/gnome-icon-theme"

DOCS="AUTHORS ChangeLog NEWS README"

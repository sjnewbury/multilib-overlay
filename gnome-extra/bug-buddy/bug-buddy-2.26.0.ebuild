# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/bug-buddy/bug-buddy-2.24.2.ebuild,v 1.6 2009/03/18 15:24:12 armin76 Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="A graphical bug reporting tool"
HOMEPAGE="http://www.gnome.org/"

LICENSE="Ximian-logos GPL-2"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="eds"

# Articifially raise gtk+ dep to support loading through XSettings
RDEPEND=">=gnome-base/libbonobo-2[$(get_ml_usedeps)]
	>=dev-libs/glib-2.16.0[$(get_ml_usedeps)]
	>=gnome-base/gnome-menus-2.11.1[$(get_ml_usedeps)]
	>=dev-libs/libxml2-2.4.6[$(get_ml_usedeps)]
	>=x11-libs/gtk+-2.14.0[$(get_ml_usedeps)]
	>=net-libs/libsoup-2.4[$(get_ml_usedeps)]
	>=gnome-base/libgtop-2.13.3[$(get_ml_usedeps)]
	eds? ( >=gnome-extra/evolution-data-server-1.3[$(get_ml_usedeps)] )
	>=gnome-base/gconf-2[$(get_ml_usedeps)]
	|| ( dev-libs/elfutils dev-libs/libelf )
	>=sys-devel/gdb-5.1"

DEPEND=${RDEPEND}"
	>=app-text/gnome-doc-utils-0.3.2
	>=dev-util/pkgconfig-0.9[$(get_ml_usedeps)]
	>=dev-util/intltool-0.40"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	# Google-breakpad seems to support only x86.
	# It is mostly useless for a distro like gentoo. Disable for now.
	G2CONF="${G2CONF}
		--disable-google-breakpad
		$(use_enable eds)"
}

ml-native_pkg_setup() { :; }

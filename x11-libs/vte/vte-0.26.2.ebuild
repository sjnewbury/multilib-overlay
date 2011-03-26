# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/vte/vte-0.26.2.ebuild,v 1.8 2011/03/22 19:51:08 ranger Exp $

EAPI="3"
GCONF_DEBUG="yes"
PYTHON_DEPEND="python? 2:2.4"

inherit gnome2 python multilib-native

DESCRIPTION="Gnome terminal widget"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="debug doc glade +introspection python"

RDEPEND=">=dev-libs/glib-2.22:2[lib32?]
	>=x11-libs/gtk+-2.20:2[lib32?]
	>=x11-libs/pango-1.22.0[lib32?]
	sys-libs/ncurses[lib32?]
	glade? ( dev-util/glade:3 )
	introspection? ( >=dev-libs/gobject-introspection-0.6.7 )
	python? ( >=dev-python/pygtk-2.4[lib32?] )
	x11-libs/libX11[lib32?]
	x11-libs/libXft[lib32?]"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.13 )
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9[lib32?]
	sys-devel/gettext[lib32?]"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-maintainer-mode
		--disable-deprecation
		--disable-static
		$(use_enable debug)
		$(use_enable glade glade-catalogue)
		$(use_enable introspection)
		$(use_enable python)
		--with-html-dir=/usr/share/doc/${PF}/html
		--with-gtk=2.0"
	DOCS="AUTHORS ChangeLog HACKING NEWS README"
	use python && python_set_active_version 2
}

multilib-native_src_install_internal() {
	gnome2_src_install
	use python && python_clean_installation_image
}

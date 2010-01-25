# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/vte/vte-0.22.5.ebuild,v 1.1 2009/11/21 10:18:13 mrpouet Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

DESCRIPTION="Gnome terminal widget"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug doc glade python"

RDEPEND=">=dev-libs/glib-2.18.0[lib32?]
	>=x11-libs/gtk+-2.14.0[lib32?]
	>=x11-libs/pango-1.22.0[lib32?]
	sys-libs/ncurses[lib32?]
	glade? ( dev-util/glade:3 )
	python? ( >=dev-python/pygtk-2.4[lib32?] )
	x11-libs/libX11[lib32?]
	x11-libs/libXft[lib32?]"

DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.0 )
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9[lib32?]
	sys-devel/gettext[lib32?]"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-deprecation
		--disable-static
		$(use_enable debug)
		$(use_enable glade glade-catalogue)
		$(use_enable python)"
}

#multilib-native_src_prepare_internal() {
#	gnome2_src_prepare

	# Fix intltoolize broken file, see upstream #577133
#	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in || die "sed failed"
#}

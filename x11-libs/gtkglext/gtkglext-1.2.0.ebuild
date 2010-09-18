# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gtkglext/gtkglext-1.2.0.ebuild,v 1.20 2010/09/17 11:14:14 scarabeus Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="GL extensions for Gtk+ 2.0"
HOMEPAGE="http://gtkglext.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=dev-libs/glib-2:2[lib32?]
	>=x11-libs/gtk+-2:2[lib32?]
	>=x11-libs/pango-1[X,lib32?]
	virtual/opengl[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

DOCS="AUTHORS ChangeLog* NEWS README TODO"

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Remove development knobs, bug #308973
	sed -i 's:-D\(G.*DISABLE_DEPRECATED\):-D__\1__:g' \
		examples/Makefile.am examples/Makefile.in \
		gdk/Makefile.am gdk/Makefile.in \
		gdk/win32/Makefile.am gdk/win32/Makefile.in \
		gdk/x11/Makefile.am gdk/x11/Makefile.in \
		gtk/Makefile.am gtk/Makefile.in \
		|| die "sed failed"
}

multilib-native_src_configure_internal() {
	G2CONF="--x-libraries=/usr/$(get_libdir)"
	gnome2_src_configure
}

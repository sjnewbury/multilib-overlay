# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gtkglext/gtkglext-1.2.0.ebuild,v 1.18 2009/05/05 16:14:30 ssuominen Exp $

EAPI=2
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
	virtual/glu[lib32?]
	virtual/opengl[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

DOCS="AUTHORS ChangeLog* NEWS README TODO"

multilib-native_src_configure_internal() {
	G2CONF="--x-libraries=/usr/$(get_libdir)"
	gnome2_src_configure
}

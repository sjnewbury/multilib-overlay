# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gtkglext/gtkglext-1.2.0.ebuild,v 1.15 2008/11/17 18:36:58 dang Exp $

EAPI="2"

inherit gnome2 autotools multilib-xlibs

DESCRIPTION="GL extensions for Gtk+ 2.0"
HOMEPAGE="http://gtkglext.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2[lib32?]
	>=x11-libs/gtk+-2[lib32?]
	>=x11-libs/pango-1[X,lib32?]
	virtual/glu
	virtual/opengl"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-0.10 )
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog* INSTALL NEWS README* TODO"

multilib-xlibs_src_configure_internal() {
	G2CONF="--x-libraries=/usr/$(get_libdir)"
	gnome2_src_configure
}

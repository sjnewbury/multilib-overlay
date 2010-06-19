# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/vte/vte-0.24.1-r1.ebuild,v 1.1 2010/06/17 19:33:21 pacho Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

DESCRIPTION="Gnome terminal widget"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="debug doc glade python"

RDEPEND=">=dev-libs/glib-2.22.0[lib32?]
	>=x11-libs/gtk+-2.14.0[lib32?]
	>=x11-libs/pango-1.22.0[lib32?]
	sys-libs/ncurses[lib32?]
	glade? ( dev-util/glade:3 )
	python? ( >=dev-python/pygtk-2.4[lib32?] )
	x11-libs/libX11[lib32?]
	x11-libs/libXft[lib32?]"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.13 )
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
		$(use_enable python)
		--with-html-dir=/usr/share/doc/${PF}/html"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix ugly artifacts with upstream patches from bgo#618749
	epatch "${FILESDIR}/${P}-background-color.patch"
	epatch "${FILESDIR}/${P}-background-color2.patch"
	epatch "${FILESDIR}/${P}-cleanup-background.patch"
}
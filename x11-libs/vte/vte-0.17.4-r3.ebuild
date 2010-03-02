# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/vte/vte-0.17.4-r3.ebuild,v 1.10 2009/04/28 11:03:52 armin76 Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

DESCRIPTION="Gnome terminal widget"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
# pcre is broken in this release
IUSE="debug doc python opengl"

RDEPEND=">=dev-libs/glib-2.14[lib32?]
	>=x11-libs/gtk+-2.6[lib32?]
	>=x11-libs/pango-1.1[lib32?]
	>=media-libs/freetype-2.0.2[lib32?]
	media-libs/fontconfig[lib32?]
	sys-libs/ncurses[lib32?]
	opengl? (
		virtual/opengl[lib32?]
		virtual/glu[lib32?]
	)
	python? (
		>=dev-python/pygtk-2.4[lib32?]
		>=dev-lang/python-2.4.4-r5[lib32?]
	)
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
		$(use_enable debug)
		$(use_enable python)
		$(use_with opengl glX)
		--with-xft2 --with-pangox"
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/${P}-fix-highlighting-on-activity.patch"
	# Bug #249618
	epatch "${FILESDIR}/${P}-no-null-backspace.patch"
}

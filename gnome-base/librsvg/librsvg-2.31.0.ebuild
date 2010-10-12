# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/librsvg/librsvg-2.31.0.ebuild,v 1.4 2010/09/25 14:56:05 nirbheek Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit gnome2 multilib eutils autotools multilib-native

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="http://librsvg.sourceforge.net/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc +gtk tools" # +gtk3

RDEPEND=">=media-libs/fontconfig-1.0.1[lib32?]
	>=media-libs/freetype-2[lib32?]
	>=dev-libs/glib-2.24[lib32?]
	>=x11-libs/cairo-1.2[lib32?]
	>=x11-libs/pango-1.10[lib32?]
	>=dev-libs/libxml2-2.4.7[lib32?]
	>=dev-libs/libcroco-0.6.1[lib32?]
	|| ( x11-libs/gdk-pixbuf
		x11-libs/gtk+:2[lib32?] )
	gtk? ( >=x11-libs/gtk+-2.16:2[lib32?] )"
#	gtk3? ( >=x11-libs/gtk+-2.90:3 )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12[lib32?]
	>=dev-util/gtk-doc-am-1.13
	doc? ( >=dev-util/gtk-doc-1 )"
# >=dev-util/gtk-doc-am-1.13 needed by eautoreconf

DOCS="AUTHORS ChangeLog README NEWS TODO"

multilib-native_pkg_setup_internal() {
	# croco is forced on to respect SVG specification
	G2CONF="${G2CONF}
		--disable-static
		$(use_enable tools)
		--with-croco
		--enable-pixbuf-loader
		$(use_with gtk gtk2)
		--without-gtk3"
#		$(use_with gtk3)"
#	if use gtk || use gtk3; then
	if use gtk; then
		G2CONF="${G2CONF} --enable-gtk-theme"
	else
		G2CONF="${G2CONF} --disable-gtk-theme"
	fi
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	epatch "${FILESDIR}"/${P}-skip-automagic.patch

	eautoreconf
}

multilib-native_src_install_internal() {
	gnome2_src_install

	# Remove .la files, these libraries are dlopen()-ed.
	rm -vf "${ED}"/usr/lib*/gtk-2.0/*/engines/libsvg.la
	rm -vf "${ED}"/usr/lib*/gdk-pixbuf-2.0/*/loaders/libpixbufloader-svg.la
}

multilib-native_pkg_postinst_internal() {
	gdk-pixbuf-query-loaders > "${EROOT}/usr/$(get_libdir)/gdk-pixbuf-2.0/2.10.0/loaders.cache"
}

multilib-native_pkg_postrm_internal() {
	gdk-pixbuf-query-loaders > "${EROOT}/usr/$(get_libdir)/gdk-pixbuf-2.0/2.10.0/loaders.cache"
}

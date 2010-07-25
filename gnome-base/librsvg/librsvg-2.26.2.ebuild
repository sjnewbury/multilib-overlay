# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/librsvg/librsvg-2.26.2.ebuild,v 1.7 2010/07/20 04:38:41 jer Exp $

EAPI="2"

inherit autotools eutils gnome2 multilib multilib-native

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="http://librsvg.sourceforge.net/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~mips ~ppc ppc64 ~sh ~sparc x86 ~x86-fbsd"
IUSE="doc tools zlib"

RDEPEND=">=media-libs/fontconfig-1.0.1[lib32?]
	>=media-libs/freetype-2[lib32?]
	>=x11-libs/gtk+-2.16[lib32?]
	>=dev-libs/glib-2.15.4[lib32?]
	>=x11-libs/cairo-1.2[lib32?]
	>=x11-libs/pango-1.10[lib32?]
	>=dev-libs/libxml2-2.4.7[lib32?]
	>=dev-libs/libcroco-0.6.1[lib32?]
	zlib? ( >=gnome-extra/libgsf-1.6[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12[lib32?]
	>=dev-util/gtk-doc-am-1.13
	doc? ( >=dev-util/gtk-doc-1 )"
# >=dev-util/gtk-doc-am-1.13 needed by eautoreconf, feel free to drop it when not run it

DOCS="AUTHORS ChangeLog README NEWS TODO"

multilib-native_pkg_setup_internal() {
	# croco is forced on to respect SVG specification
	G2CONF="${G2CONF}
		$(use_enable tools)
		$(use_with zlib svgz)
		--with-croco
		--enable-pixbuf-loader
		--enable-gtk-theme"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# gcc-4.3.2-r3 related segfault with various apps like firefox -- bug 239992
	epatch "${FILESDIR}/${PN}-2.22.3-fix-segfault-with-firefox.patch"

	# Build extra tools only when desired, bug 226231
	epatch "${FILESDIR}/${P}-choosable-tools.patch"
	eautoreconf
}

set_gtk_confdir() {
	# An arch specific config directory is used on multilib systems
	has_multilib_profile && GTK2_CONFDIR="${ROOT}etc/gtk-2.0/${CHOST}"
	GTK2_CONFDIR="${GTK2_CONFDIR:-/etc/gtk-2.0}"
}

multilib-native_src_install_internal() {
	gnome2_src_install

	# remove gdk-pixbuf loaders (#47766)
	rm -fr "${D}/etc"
}

multilib-native_pkg_postinst_internal() {
	set_gtk_confdir
	gdk-pixbuf-query-loaders > "${GTK2_CONFDIR}/gdk-pixbuf.loaders"
}

multilib-native_pkg_postrm_internal() {
	set_gtk_confdir
	gdk-pixbuf-query-loaders > "${GTK2_CONFDIR}/gdk-pixbuf.loaders"
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/gimp/gimp-2.6.8.ebuild,v 1.3 2009/12/20 18:23:01 pacho Exp $

EAPI=2

inherit eutils gnome2 fdo-mime multilib python multilib-native

DESCRIPTION="GNU Image Manipulation Program"
HOMEPAGE="http://www.gimp.org/"
SRC_URI="mirror://gimp/v2.6/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ~ppc ppc64 ~sparc ~x86"

IUSE="alsa aalib altivec curl dbus debug doc exif gnome hal jpeg lcms mmx mng pdf png python smp sse svg tiff webkit wmf"

RDEPEND=">=dev-libs/glib-2.18.1[lib32?]
	>=x11-libs/gtk+-2.12.5[lib32?]
	>=x11-libs/pango-1.18.0[lib32?]
	>=media-libs/freetype-2.1.7[lib32?]
	>=media-libs/fontconfig-2.2.0[lib32?]
	sys-libs/zlib[lib32?]
	dev-libs/libxml2[lib32?]
	dev-libs/libxslt[lib32?]
	x11-misc/xdg-utils
	x11-themes/hicolor-icon-theme
	>=media-libs/gegl-0.0.22[lib32?]
	aalib? ( media-libs/aalib[lib32?] )
	alsa? ( media-libs/alsa-lib[lib32?] )
	curl? ( net-misc/curl[lib32?] )
	dbus? ( dev-libs/dbus-glib[lib32?] )
	hal? ( sys-apps/hal[lib32?] )
	gnome? ( gnome-base/gvfs[lib32?] )
	webkit? ( net-libs/webkit-gtk[lib32?] )
	jpeg? ( >=media-libs/jpeg-6b-r2[lib32?] )
	exif? ( >=media-libs/libexif-0.6.15[lib32?] )
	lcms? ( media-libs/lcms[lib32?] )
	mng? ( media-libs/libmng[lib32?] )
	pdf? ( >=virtual/poppler-glib-0.3.1[cairo,lib32?] )
	png? ( >=media-libs/libpng-1.2.2[lib32?] )
	python?	( >=dev-lang/python-2.5.0[lib32?]
		>=dev-python/pygtk-2.10.4[lib32?] )
	tiff? ( >=media-libs/tiff-3.5.7[lib32?] )
	svg? ( >=gnome-base/librsvg-2.8.0[lib32?] )
	wmf? ( >=media-libs/libwmf-0.2.8[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12.0[lib32?]
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog* HACKING NEWS README*"

multilib-native_pkg_setup_internal() {
	G2CONF="--enable-default-binary \
		--with-x \
		$(use_with aalib aa) \
		$(use_with alsa) \
		$(use_enable altivec) \
		$(use_with curl libcurl) \
		$(use_with dbus) \
		$(use_with hal) \
		$(use_with gnome gvfs) \
		--without-gnomevfs \
		$(use_with webkit) \
		$(use_with jpeg libjpeg) \
		$(use_with exif libexif) \
		$(use_with lcms) \
		$(use_enable mmx) \
		$(use_with mng libmng) \
		$(use_with pdf poppler) \
		$(use_with png libpng) \
		$(use_enable python) \
		$(use_enable smp mp) \
		$(use_enable sse) \
		$(use_with svg librsvg) \
		$(use_with tiff libtiff) \
		$(use_with wmf)"
}

pkg_postinst() {
	gnome2_pkg_postinst

	python_mod_optimize /usr/$(get_libdir)/gimp/2.0/python \
		/usr/$(get_libdir)/gimp/2.0/plug-ins
}

pkg_postrm() {
	gnome2_pkg_postrm
	python_mod_cleanup /usr/$(get_libdir)/gimp/2.0/python \
		/usr/$(get_libdir)/gimp/2.0/plug-ins
}

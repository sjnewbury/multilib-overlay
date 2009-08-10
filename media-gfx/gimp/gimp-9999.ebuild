# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/gimp/gimp-9999.ebuild,v 1.21 2009/08/01 06:46:42 ssuominen Exp $

EAPI=2

inherit subversion fdo-mime flag-o-matic multilib python multilib-native

ESVN_REPO_URI="http://svn.gnome.org/svn/gimp/trunk/"

DESCRIPTION="GNU Image Manipulation Program"
HOMEPAGE="http://www.gimp.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="2"
KEYWORDS=""

IUSE="alsa aalib altivec curl dbus debug doc gtkhtml gnome jpeg lcms mmx mng pdf png python smp sse svg tiff wmf"

RDEPEND=">=dev-libs/glib-2.12.3[lib32?]
	>=x11-libs/gtk+-2.10.6[lib32?]
	>=x11-libs/pango-1.12.2[lib32?]
	>=media-libs/freetype-2.1.7[lib32?]
	>=media-libs/fontconfig-2.2.0[lib32?]
	>=media-libs/libart_lgpl-2.3.8-r1[lib32?]
	sys-libs/zlib[lib32?]
	dev-libs/libxml2[lib32?]
	dev-libs/libxslt[lib32?]
	x11-themes/hicolor-icon-theme
	aalib? ( media-libs/aalib[lib32?] )
	alsa? ( media-libs/alsa-lib[lib32?] )
	curl? ( net-misc/curl[lib32?] )
	dbus? ( dev-libs/dbus-glib[lib32?]
		sys-apps/hal[lib32?] )
	gnome? ( >=gnome-base/gnome-vfs-2.10.0[lib32?]
		>=gnome-base/libgnomeui-2.10.0[lib32?]
		>=gnome-base/gnome-keyring-0.4.5[lib32?] )
	gtkhtml? ( =gnome-extra/gtkhtml-2*[lib32?] )
	jpeg? ( >=media-libs/jpeg-6b-r2[lib32?]
		>=media-libs/libexif-0.6.15[lib32?] )
	lcms? ( media-libs/lcms[lib32?] )
	mng? ( media-libs/libmng[lib32?] )
	pdf? ( >=virtual/poppler-glib-0.3.1[cairo,lib32?] )
	png? ( >=media-libs/libpng-1.2.2[lib32?] )
	python?	( >=dev-lang/python-2.2.1[lib32?]
		>=dev-python/pygtk-2.10.4[lib32?] )
	tiff? ( >=media-libs/tiff-3.5.7[lib32?] )
	svg? ( >=gnome-base/librsvg-2.8.0[lib32?] )
	wmf? ( >=media-libs/libwmf-0.2.8[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12.0[lib32?]
	>=dev-util/intltool-0.31
	>=sys-devel/gettext-0.17[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

multilib-native_src_configure_internal() {
	# workaround portage variable leakage
	local AA=

	# gimp uses inline functions (e.g. plug-ins/common/grid.c) (#23078)
	# gimp uses floating point math, needs accuracy (#98685)
	filter-flags "-fno-inline" "-ffast-math"
	# gimp assumes char is signed (fixes preview corruption)
	if use ppc || use ppc64; then
		append-flags "-fsigned-char"
	fi

	sed -i -e 's:\$srcdir/configure:#:g' autogen.sh
	"${S}"/autogen.sh $(use_enable doc gtk-doc) || die

	econf --enable-default-binary \
		--with-x \
		$(use_with aalib aa) \
		$(use_with alsa) \
		$(use_enable altivec) \
		$(use_with curl) \
		$(use_enable debug) \
		$(use_enable doc gtk-doc) \
		$(use_with dbus) \
		$(use_with gnome) \
		$(use_with gtkhtml gtkhtml2) \
		$(use_with jpeg libjpeg) \
		$(use_with jpeg libexif) \
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
		$(use_with wmf) \
		|| die "econf failed"
}

multilib-native_src_compile_internal() {
	# workaround portage variable leakage
	local AA=
	emake || die "emake failed"
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc AUTHORS ChangeLog* HACKING NEWS README*
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

	elog
	elog "If you want Postscript file support, emerge ghostscript."
	elog

	python_mod_optimize /usr/$(get_libdir)/gimp/2.0/python \
		/usr/$(get_libdir)/gimp/2.0/plug-ins
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	python_mod_cleanup /usr/$(get_libdir)/gimp/2.0/python \
		/usr/$(get_libdir)/gimp/2.0/plug-ins
}

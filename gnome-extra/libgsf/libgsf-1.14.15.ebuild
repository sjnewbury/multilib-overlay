# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/libgsf/libgsf-1.14.15.ebuild,v 1.13 2010/09/26 22:14:11 eva Exp $

EAPI="2"

inherit eutils gnome2 python multilib multilib-native

DESCRIPTION="The GNOME Structured File Library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="ppc64"
IUSE="bzip2 doc gnome python"

RDEPEND="
	>=dev-libs/glib-2.16[lib32?]
	>=dev-libs/libxml2-2.4.16[lib32?]
	gnome? ( >=gnome-base/gconf-2[lib32?]
		>=gnome-base/libbonobo-2[lib32?]
		>=gnome-base/gnome-vfs-2.2[lib32?] )
	sys-libs/zlib[lib32?]
	bzip2? ( app-arch/bzip2[lib32?] )
	python? ( dev-lang/python[lib32?]
		>=dev-python/pygobject-2.10[lib32?]
		>=dev-python/pygtk-2.10[lib32?] )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	>=dev-util/intltool-0.35.0
	doc? ( >=dev-util/gtk-doc-1 )"

PDEPEND="gnome? ( media-gfx/imagemagick )"

DOCS="AUTHORS BUGS ChangeLog HACKING NEWS README TODO"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--with-gio
		--disable-static
		$(use_with bzip2 bz2)
		$(use_with gnome gnome-vfs)
		$(use_with gnome bonobo)
		$(use_with python)"
}

multilib-native_src_unpack_internal() {
	gnome2_src_unpack

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile
}

multilib-native_pkg_preinst_internal() {
	gnome2_pkg_preinst
	preserve_old_lib /usr/$(get_libdir)/libgsf-1.so.1
	preserve_old_lib /usr/$(get_libdir)/libgsf-gnome-1.so.1
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst
	if use python; then
		python_need_rebuild
		python_mod_optimize $(python_get_sitedir)/gsf
	fi

	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-1.so.1
	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-gnome-1.so.1
}

multilib-native_pkg_postrm_internal() {
	gnome2_pkg_postrm
	python_mod_cleanup /usr/$(get_libdir)/python*/site-packages/gsf
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-menus/gnome-menus-2.20.3.ebuild,v 1.11 2009/05/10 18:43:15 eva Exp $

EAPI="2"

inherit eutils gnome2 python multilib linux-info multilib-native

DESCRIPTION="The GNOME menu system, implementing the F.D.O cross-desktop spec"
HOMEPAGE="http://www.gnome.org"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="arm sh"
IUSE="debug python kernel_linux"

RDEPEND=">=dev-libs/glib-2.6[lib32?]
	python? (
		>=dev-lang/python-2.4.4-r5[lib32?]
		dev-python/pygtk[lib32?]
	)"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.35"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

multilib-native_pkg_setup_internal() {
	if use kernel_linux ; then
		CONFIG_CHECK="~INOTIFY"
		linux-info_pkg_setup
	fi

	G2CONF="${G2CONF}
		$(use_enable kernel_linux inotify)
		$(use_enable debug)
		$(use_enable python)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Don't show KDE standalone settings desktop files in GNOME others menu
	epatch "${FILESDIR}/${PN}-2.18.3-ignore_kde_standalone.patch"

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst
	if use python; then
		python_version
		python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/GMenuSimpleEditor
	fi
}

multilib-native_pkg_postrm_internal() {
	gnome2_pkg_postrm
	if use python; then
		python_mod_cleanup /usr/$(get_libdir)/python*/site-packages/GMenuSimpleEditor
	fi
}

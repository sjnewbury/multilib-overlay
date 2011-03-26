# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgweather/libgweather-2.30.3.ebuild,v 1.10 2011/03/22 18:53:37 ranger Exp $

EAPI="2"
GCONF_DEBUG="no"
PYTHON_DEPEND="python? 2"

inherit autotools gnome2 python multilib-native

DESCRIPTION="Library to access weather information from online services"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="python doc"

# libsoup-gnome is to be used because libsoup[gnome] might not
# get libsoup-gnome installed by the time ${P} is built
RDEPEND=">=x11-libs/gtk+-2.11:2[lib32?]
	>=dev-libs/glib-2.13:2[lib32?]
	>=gnome-base/gconf-2.8:2[lib32?]
	>=net-libs/libsoup-gnome-2.25.1:2.4[lib32?]
	>=dev-libs/libxml2-2.6.0:2[lib32?]
	>=sys-libs/timezone-data-2010k
	python? (
		>=dev-python/pygobject-2[lib32?]
		>=dev-python/pygtk-2[lib32?] )
	!<gnome-base/gnome-applets-2.22.0"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40.3
	>=dev-util/pkgconfig-0.19[lib32?]
	>=dev-util/gtk-doc-am-1.9
	doc? ( >=dev-util/gtk-doc-1.9 )"

DOCS="AUTHORS ChangeLog MAINTAINERS NEWS"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--enable-locations-compression
		--disable-all-translations-in-one-xml
		--disable-static
		$(use_enable python)"
	use python && python_set_active_version 2
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix building -python, Gnome bug #596660.
	epatch "${FILESDIR}/${PN}-2.30.0-fix-automagic-python-support.patch"

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

multilib-native_src_install_internal() {
	gnome2_src_install
	python_clean_installation_image
}

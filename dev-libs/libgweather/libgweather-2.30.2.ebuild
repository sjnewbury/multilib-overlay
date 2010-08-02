# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgweather/libgweather-2.30.2.ebuild,v 1.4 2010/08/01 11:32:32 fauli Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools gnome2 multilib-native

DESCRIPTION="Library to access weather information from online services"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd"
IUSE="python doc"

RDEPEND=">=x11-libs/gtk+-2.11[lib32?]
	>=dev-libs/glib-2.13[lib32?]
	>=gnome-base/gconf-2.8[lib32?]
	>=net-libs/libsoup-2.25.1:2.4[gnome,lib32?]
	>=dev-libs/libxml2-2.6.0[lib32?]
	python? (
		>=dev-python/pygobject-2[lib32?]
		>=dev-python/pygtk-2[lib32?] )
	!<gnome-base/gnome-applets-2.22.0"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40.3
	>=dev-util/pkgconfig-0.19[lib32?]
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1.9 )"

DOCS="AUTHORS ChangeLog MAINTAINERS NEWS"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--enable-locations-compression
		--disable-all-translations-in-one-xml
		--disable-static
		$(use_enable python)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# FIXME: tarball generated with broken gtk-doc, revisit me.
	if use doc; then
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=/usr/bin/gtkdoc-rebase" \
			-i gtk-doc.make || die "sed 1 failed"
	else
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=/$(type -P true)" \
			-i gtk-doc.make || die "sed 2 failed"
	fi
	# Fix building -python, Gnome bug #596660.
	epatch "${FILESDIR}/${PN}-2.30.0-fix-automagic-python-support.patch"

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

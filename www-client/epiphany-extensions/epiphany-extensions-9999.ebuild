# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/epiphany-extensions/epiphany-extensions-2.24.1-r10.ebuild,v 1.2 2008/11/12 08:17:28 jer Exp $

EAPI="2"

inherit eutils autotools gnome2 python versionator subversion multilib-native

MY_MAJORV="2.27"
#$(get_version_component_range 1-2)

DESCRIPTION="Extensions for the Epiphany web browser"
HOMEPAGE="http://www.gnome.org/projects/epiphany/extensions.html"
LICENSE="GPL-2"
SRC_URI=""
ESVN_REPO_URI="svn://svn.gnome.org/svn/${PN}/trunk"

SLOT="0"
KEYWORDS=""
IUSE="dbus examples pcre python"

RDEPEND=">=www-client/epiphany-${MY_MAJORV}[lib32?]
	app-text/opensp[lib32?]
	>=dev-libs/glib-2.15.5[lib32?]
	>=gnome-base/gconf-2.0[lib32?]
	>=dev-libs/libxml2-2.6[lib32?]
	>=x11-libs/gtk+-2.11.6[lib32?]
	>=gnome-base/libglade-2[lib32?]
	dbus? ( >=dev-libs/dbus-glib-0.34[lib32?] )
	pcre? ( >=dev-libs/libpcre-3.9-r2[lib32?] )
	python? ( >=dev-python/pygtk-2.11 )"
DEPEND="${RDEPEND}
	  gnome-base/gnome-common
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.20[lib32?]
	>=app-text/gnome-doc-utils-0.3.2"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	gnome2_omf_fix

	# disable pyc compiling
	#mv py-compile py-compile.orig
	#ln -s $(type -P true) py-compile

	# Don't remove sessionsaver, please.  -dang
#	epatch "${FILESDIR}"/${P}-sessionsaver-v4.patch.gz
#	echo "extensions/sessionsaver/ephy-sessionsaver-extension.c" >> po/POTFILES.in

	intltoolize --force --automake
	gnome-doc-prepare --force --automake
	eautoreconf
}

pkg_setup() {
	local extensions=""

	extensions="actions auto-reload auto-scroller certificates error-viewer \
				extensions-manager-ui gestures java-console \
				livehttpheaders page-info permissions push-scroller \
				select-stylesheet sidebar smart-bookmarks tab-groups \
				tab-states"

	use dbus && extensions="${extensions} rss"

	use pcre && extensions="${extensions} adblock greasemonkey"

	use python && extensions="${extensions} python-console favicon cc-license-viewer"
	use python && use examples && extensions="${extensions} sample-python"

	use examples && extensions="${extensions} sample"

	G2CONF="${G2CONF} --with-extensions=$(echo "${extensions}" | sed -e 's/[[:space:]]\+/,/g')"
}

pkg_postinst() {
	gnome2_pkg_postinst

	if use python; then
		python_mod_optimize /usr/$(get_libdir)/epiphany/${MY_MAJORV}/extensions
	fi
}

pkg_postrm() {
	gnome2_pkg_postrm

	if use python; then
		python_mod_cleanup /usr/$(get_libdir)/epiphany/${MY_MAJORV}/extensions
	fi
}

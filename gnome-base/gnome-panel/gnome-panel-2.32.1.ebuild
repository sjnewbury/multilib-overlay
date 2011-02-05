# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-panel/gnome-panel-2.32.1.ebuild,v 1.4 2011/02/04 11:03:45 pacho Exp $

EAPI="3"
GCONF_DEBUG="no"
PYTHON_DEPEND="2:2.4"

inherit gnome2 python multilib-native

DESCRIPTION="The GNOME panel"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 FDL-1.1 LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="+bonobo doc eds +introspection networkmanager"

RDEPEND=">=gnome-base/gnome-desktop-2.26:2[lib32?]
	>=x11-libs/pango-1.15.4[introspection?,lib32?]
	>=dev-libs/glib-2.25.12:2[lib32?]
	>=x11-libs/gtk+-2.22:2[introspection?,lib32?]
	>=dev-libs/libgweather-2.27.90:2[lib32?]
	dev-libs/libxml2[lib32?]
	>=gnome-base/gconf-2.6.1[introspection?,lib32?]
	>=media-libs/libcanberra-0.23[gtk,lib32?]
	>=gnome-base/gnome-menus-2.27.92[lib32?]
	gnome-base/librsvg[lib32?]
	>=dev-libs/dbus-glib-0.80[lib32?]
	>=sys-apps/dbus-1.1.2[lib32?]
	>=x11-libs/cairo-1[lib32?]
	x11-libs/libXau[lib32?]
	>=x11-libs/libXrandr-1.2[lib32?]
	bonobo? (
		>=gnome-base/libbonobo-2.20.4[lib32?]
		>=gnome-base/libbonoboui-2.1.1[lib32?]
		>=gnome-base/orbit-2.4[lib32?]
		>=x11-libs/libwnck-2.19.5[lib32?] )
	eds? ( >=gnome-extra/evolution-data-server-1.6[lib32?] )
	introspection? ( >=dev-libs/gobject-introspection-0.6.7 )
	networkmanager? ( >=net-misc/networkmanager-0.6.7[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5[lib32?]
	>=app-text/gnome-doc-utils-0.3.2[lib32?]
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.40
	~app-text/docbook-xml-dtd-4.1.2
	doc? ( >=dev-util/gtk-doc-1 )"
# eautoreconf needs
#	gnome-base/gnome-common
#	dev-util/gtk-doc-am

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-deprecation-flags
		--disable-static
		--disable-scrollkeeper
		--disable-schemas-install
		--with-in-process-applets=clock,notification-area,wncklet
		$(use_enable bonobo)
		$(use_enable networkmanager network-manager)
		$(use_enable introspection)
		$(use_enable eds)"
	DOCS="AUTHORS ChangeLog HACKING NEWS README"
	python_set_active_version 2
}

multilib-native_pkg_postinst_internal() {
	local entries="${EROOT}etc/gconf/schemas/panel-default-setup.entries"
	local gconftool="${EROOT}usr/bin/gconftool-2"

	if [ -e "$entries" ]; then
		einfo "Setting panel gconf defaults..."

		GCONF_CONFIG_SOURCE="$("${gconftool}" --get-default-source | sed "s;:/;:${ROOT};")"

		"${gconftool}" --direct --config-source \
			"${GCONF_CONFIG_SOURCE}" --load="${entries}"
	fi

	# Calling this late so it doesn't process the GConf schemas file we already
	# took care of.
	gnome2_pkg_postinst
}

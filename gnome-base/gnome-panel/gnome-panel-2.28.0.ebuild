# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-panel/gnome-panel-2.28.0.ebuild,v 1.11 2010/07/19 22:12:53 jer Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit autotools eutils gnome2 multilib-native

DESCRIPTION="The GNOME panel"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 FDL-1.1 LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc eds networkmanager policykit"

RDEPEND="dev-lang/python[lib32?]
	>=gnome-base/gnome-desktop-2.26.0[lib32?]
	>=x11-libs/pango-1.15.4[lib32?]
	>=dev-libs/glib-2.18.0[lib32?]
	>=x11-libs/gtk+-2.15.1[lib32?]
	>=dev-libs/libgweather-2.27.90[lib32?]
	dev-libs/libxml2[lib32?]
	>=gnome-base/libgnome-2.13[lib32?]
	>=gnome-base/libgnomeui-2.5.4[lib32?]
	>=gnome-base/libbonoboui-2.1.1[lib32?]
	>=gnome-base/orbit-2.4[lib32?]
	>=x11-libs/libwnck-2.19.5[lib32?]
	>=gnome-base/gconf-2.6.1[lib32?]
	>=gnome-base/gnome-menus-2.27.92[lib32?]
	>=gnome-base/libbonobo-2.20.4[lib32?]
	gnome-base/librsvg[lib32?]
	>=dev-libs/dbus-glib-0.71[lib32?]
	>=sys-apps/dbus-1.1.2[lib32?]
	>=x11-libs/cairo-1[lib32?]
	x11-libs/libXau[lib32?]
	>=x11-libs/libXrandr-1.2[lib32?]
	eds? ( >=gnome-extra/evolution-data-server-1.6[lib32?] )
	networkmanager? ( >=net-misc/networkmanager-0.6[lib32?] )
	policykit? ( >=sys-auth/polkit-0.91[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5[lib32?]
	gnome-base/gnome-common
	>=app-text/gnome-doc-utils-0.3.2[lib32?]
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.40
	~app-text/docbook-xml-dtd-4.1.2
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-static
		--disable-scrollkeeper
		--disable-schemas-install
		--with-in-process-applets=clock,notification-area,wncklet
		$(use_enable policykit polkit)
		$(use_enable networkmanager network-manager)
		$(use_enable eds)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# FIXME: tarball generated with broken gtk-doc, revisit me.
	if use doc; then
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=${EPREFIX}/usr/bin/gtkdoc-rebase" \
			-i gtk-doc.make || die "sed 1 failed"
	else
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=$(type -P true)" \
			-i gtk-doc.make || die "sed 2 failed"
	fi

	# Fix missing cflags for clock applet, bug #287853
	epatch "${FILESDIR}/${P}-clock-applet-missing-cflags.patch"

	# Fix crashes in various conditions with the new randr code,
	# import from upstream bug #597101
	epatch "${FILESDIR}/${P}-crashes-xrandr.patch"

	# Make it libtool-1 compatible, bug #271652
	rm -v m4/lt* m4/libtool.m4 || die "removing libtool macros failed"

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

multilib-native_pkg_postinst_internal() {
	local entries="${EROOT}etc/gconf/schemas/panel-default-setup.entries"
	local gconftool="${EROOT}usr/bin/gconftool-2"

	if [ -e "$entries" ]; then
		einfo "setting panel gconf defaults..."

		GCONF_CONFIG_SOURCE="$("${gconftool}" --get-default-source | sed "s;:/;:${ROOT};")"

		"${gconftool}" --direct --config-source \
			"${GCONF_CONFIG_SOURCE}" --load="${entries}"
	fi

	# Calling this late so it doesn't process the GConf schemas file we already
	# took care of.
	gnome2_pkg_postinst
}

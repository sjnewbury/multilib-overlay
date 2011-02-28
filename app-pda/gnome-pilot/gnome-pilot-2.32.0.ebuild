# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-pda/gnome-pilot/gnome-pilot-2.32.0.ebuild,v 1.5 2011/02/24 18:36:41 tomka Exp $

EAPI="3"
G2CONF_DEBUG="no"

inherit gnome2 multilib-native

DESCRIPTION="Gnome Palm Pilot and Palm OS Device Syncing Library"
HOMEPAGE="http://live.gnome.org/GnomePilot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc ~sparc x86"
IUSE="eds hal"

RDEPEND="
	|| ( gnome-base/gnome-panel[bonobo,lib32?] <gnome-base/gnome-panel-2.32[lib32?] )
	>=gnome-base/gconf-2[lib32?]
	dev-libs/libxml2[lib32?]
	>=app-pda/pilot-link-0.11.7[lib32?]
	>=x11-libs/gtk+-2.13:2[lib32?]
	>=dev-libs/dbus-glib-0.74[lib32?]

	eds? ( >=gnome-extra/evolution-data-server-2[lib32?] )
	hal? ( >=sys-apps/hal-0.5.4[lib32?] )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	sys-devel/gettext[lib32?]
	>=dev-util/gob-2.0.5
	>=dev-lang/perl-5.6[lib32?]
	>=app-text/scrollkeeper-0.3.14
	>=dev-util/intltool-0.35.5"

multilib-native_pkg_setup_internal() {
	DOCS="AUTHORS COPYING* ChangeLog README NEWS"
	G2CONF="${G2CONF}
		--disable-static
		$(use_enable eds eds-conduits)
		$(use_with hal)"
}

multilib-native_src_install_internal() {
	gnome2_src_install
	find "${ED}"/usr/$(get_libdir)/${PN}/conduits -name "*.la" -delete || die
}

multilib-native_pkg_postinst_internal() {
	if ! has_version "app-pda/pilot-link[bluetooth]"; then
		elog "if you want bluetooth support, please rebuild app-pda/pilot-link"
		elog "echo 'app-pda/pilot-link bluetooth >> /etc/portage/package.use"
	fi
}

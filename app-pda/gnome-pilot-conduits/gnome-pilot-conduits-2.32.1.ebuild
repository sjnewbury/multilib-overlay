# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-pda/gnome-pilot-conduits/gnome-pilot-conduits-2.32.1.ebuild,v 1.3 2011/02/24 18:36:12 tomka Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit gnome2 multilib-native

DESCRIPTION="Gnome Pilot Conduits"
HOMEPAGE="http://live.gnome.org/GnomePilot"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc ~sparc x86"
IUSE=""

RDEPEND="
	>=x11-libs/gtk+-2.13:2[lib32?]
	>=app-pda/gnome-pilot-2.32[lib32?]
	>=dev-libs/libxml2-2.5[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.35
	dev-util/pkgconfig[lib32?]"

multilib-native_pkg_setup_internal() {
	DOCS="AUTHORS ChangeLog NEWS README"
	G2CONF="${G2CONF} --disable-static"
}

multilib-native_src_install_internal() {
	gnome2_src_install
	find "${ED}" -name "*.la" -delete || die
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-pda/gnome-pilot/gnome-pilot-2.0.17-r1.ebuild,v 1.6 2009/10/10 14:42:48 armin76 Exp $

EAPI="2"

inherit gnome2 eutils autotools multilib-native

DESCRIPTION="Gnome Palm Pilot and Palm OS Device Syncing Library"
HOMEPAGE="http://live.gnome.org/GnomePilot"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc sparc x86"
IUSE="hal"

RDEPEND=">=gnome-base/libgnome-2.0.0[lib32?]
	>=gnome-base/libgnomeui-2.0.0[lib32?]
	>=gnome-base/libglade-2.0.0[lib32?]
	>=gnome-base/orbit-2.6.0[lib32?]
	>=gnome-base/libbonobo-2.0.0[lib32?]
	>=gnome-base/gnome-panel-2.0[lib32?]
	>=gnome-base/gconf-2.0[lib32?]
	dev-libs/libxml2[lib32?]
	>=app-pda/pilot-link-0.11.7[lib32?]
	hal? (
		dev-libs/dbus-glib[lib32?]
		>=sys-apps/hal-0.5.4[lib32?]
	)"

DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/gob-2.0.5
	>=dev-lang/perl-5.6.0[lib32?]
	>=app-text/scrollkeeper-0.3.14
	dev-util/intltool"

DOCS="AUTHORS COPYING* ChangeLog README NEWS"
SCROLLKEEPER_UPDATE="0"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--enable-usb
		--enable-network
		--enable-pilotlinktest
		$(use_with hal)"
}

multilib-native_src_prepare_internal() {
	echo "libgpilotdCM/gnome-pilot-conduit-management.c" >> po/POTFILES.in

	# Fix --as-needed
	epatch "${FILESDIR}/${PN}-2.0.15-as-needed.patch"

	# Fix bug #282354, applet didn't appear into the panel,
	# due to missing call to gnome_programm_init().
	# Patch import from upstream bug #584894.
	epatch "${FILESDIR}/${P}-invisible-applet.patch"

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

pkg_postinst() {
	if ! built_with_use --missing false app-pda/pilot-link bluetooth; then
		elog "if you want bluetooth support, please rebuild app-pda/pilot-link"
		elog "echo 'app-pda/pilot-link bluetooth >> /etc/portage/package.use"
	fi
}

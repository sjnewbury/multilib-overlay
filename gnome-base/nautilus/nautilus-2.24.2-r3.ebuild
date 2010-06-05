# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/nautilus/nautilus-2.24.2-r3.ebuild,v 1.8 2009/10/28 22:06:30 eva Exp $

EAPI="2"

inherit gnome2 eutils virtualx multilib-native

DESCRIPTION="A file manager for the GNOME desktop"
HOMEPAGE="http://www.gnome.org/projects/nautilus/"

LICENSE="GPL-2 LGPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="beagle doc gnome tracker xmp"

RDEPEND=">=gnome-base/libbonobo-2.1[lib32?]
	>=gnome-base/eel-2.24.0
	>=dev-libs/glib-2.17.5[lib32?]
	>=gnome-base/gnome-desktop-2.10[lib32?]
	>=gnome-base/libgnome-2.14[lib32?]
	>=gnome-base/libgnomeui-2.6[lib32?]
	>=gnome-base/orbit-2.4[lib32?]
	>=x11-libs/pango-1.1.2[lib32?]
	>=x11-libs/gtk+-2.13.0[lib32?]
	>=gnome-base/librsvg-2.0.1[lib32?]
	>=dev-libs/libxml2-2.4.7[lib32?]
	>=x11-libs/startup-notification-0.8[lib32?]
	>=media-libs/libexif-0.5.12[lib32?]
	>=gnome-base/gconf-2.0[lib32?]
	>=gnome-base/gvfs-0.1.2[lib32?]
	beagle? ( || (
		dev-libs/libbeagle[lib32?]
		=app-misc/beagle-0.2* ) )
	tracker? ( >=app-misc/tracker-0.6.4[lib32?] )
	xmp? ( >=media-libs/exempi-2[lib32?] )"

DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.35
	doc? ( >=dev-util/gtk-doc-1.4 )"

PDEPEND="gnome? ( >=x11-themes/gnome-icon-theme-1.1.91 )"

DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS README THANKS TODO"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-update-mimedb
		$(use_enable beagle)
		$(use_enable tracker)
		$(use_enable xmp)"
}

multilib-native_src_prepare_internal() {
	# Fix update of scrollbars, bug #260965
	epatch "${FILESDIR}/${P}-scrollbars.patch"

	# Fix preview on playlists, bug #263162
	epatch "${FILESDIR}/${P}-playlist-preview.patch"

	# Fix non asyncness in custom icon filechooser, bug #263165
	epatch "${FILESDIR}/${P}-filechooser-icon.patch"

	# Fix scaling of thumbnails, bug #261219
	epatch "${FILESDIR}/${P}-thumbnail-scaling.patch"
}

src_test() {
	addwrite "/root/.gnome2_private"
	unset SESSION_MANAGER
	unset ORBIT_SOCKETDIR
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check || die "Test phase failed"
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst

	elog "nautilus can use gstreamer to preview audio files. Just make sure"
	elog "to have the necessary plugins available to play the media type you"
	elog "want to preview"
}

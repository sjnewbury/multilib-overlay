# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/epiphany/epiphany-2.22.3-r10.ebuild,v 1.1 2008/07/06 11:19:35 eva Exp $

EAPI="2"

inherit gnome2 eutils multilib subversion autotools multilib-native

DESCRIPTION="GNOME webbrowser based on the mozilla rendering engine"
HOMEPAGE="http://www.gnome.org/projects/epiphany/"
SRC_URI=""
ESVN_REPO_URI="svn://svn.gnome.org/svn/${PN}/trunk"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="avahi doc networkmanager python"
#spell

# This revision is meant to work with xulrunner 1.9, an earlier revision
# is the earlier stable candidate against xulrunner-1.8 and co.

RDEPEND=">=dev-libs/glib-2.18.0[lib32?]
	>=x11-libs/gtk+-2.14.0[lib32?]
	>=dev-libs/libxml2-2.6.12[lib32?]
	>=dev-libs/libxslt-1.1.7[lib32?]
	>=gnome-base/libglade-2.3.1[lib32?]
	>=gnome-base/libgnome-2.14[lib32?]
	>=gnome-base/libgnomeui-2.14[lib32?]
	>=gnome-base/gnome-desktop-2.9.91[lib32?]
	>=x11-libs/startup-notification-0.5[lib32?]
	>=x11-libs/libnotify-0.4[lib32?]
	>=media-libs/libcanberra-0.3[lib32?]
	>=dev-libs/dbus-glib-0.71[lib32?]
	>=gnome-base/gconf-2[lib32?]
	>=app-text/iso-codes-0.35
	avahi? ( >=net-dns/avahi-0.6.22[lib32?] )
	networkmanager? ( net-misc/networkmanager[lib32?] )
	net-libs/webkit-gtk[lib32?]
	python? (
		>=dev-lang/python-2.3[lib32?]
		>=dev-python/pygtk-2.7.1
		>=dev-python/gnome-python-2.6
	)
	spell? ( app-text/enchant )
	x11-themes/gnome-icon-theme"
DEPEND="${RDEPEND}
	app-text/scrollkeeper
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.40
	>=app-text/gnome-doc-utils-0.3.2
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS README TODO"

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	gnome2_omf_fix

	intltoolize --force --automake
	gtkdocize
	gnome-doc-prepare --force --automake
	eautoreconf
}

pkg_setup() {
	# FIXME: I'm automagic
	if ! built_with_use media-libs/libcanberra gtk; then
		eerror "You need to rebuild media-libs/libcanberra with gtk support."
		die "Rebuild media-libs/libcanberra with USE='gtk'"
	fi
}

multilib-native_src_configure_internal() {
	G2CONF="${G2CONF}
		--disable-scrollkeeper
		--with-distributor-name=Gentoo
		--disable-compile-warnings
		--disable-tests
		$(use_enable avahi zeroconf)
		$(use_enable networkmanager network-manager)
		$(use_enable python)"

#		--enable-certificate-manager
#		$(use_enable spell spell-checker)

	if use lib32 && ! is_final_abi; then
		gnome2_src_configure "--program-suffix=-${ABI}"
	else
		gnome2_src_configure
	fi
}

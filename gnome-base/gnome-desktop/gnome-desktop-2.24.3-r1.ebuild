# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-desktop/gnome-desktop-2.24.3-r1.ebuild,v 1.10 2010/07/20 01:50:19 jer Exp $

EAPI="2"

inherit eutils autotools gnome2 multilib-native

DESCRIPTION="Libraries for the gnome desktop that are not part of the UI"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 FDL-1.1 LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

# FIXME: Python deps are needed for gnome-about but not
# listed in configure.ac
RDEPEND=">=dev-libs/libxml2-2.4.20[lib32?]
	>=x11-libs/gtk+-2.11.3[lib32?]
	>=dev-libs/glib-2.15.4[lib32?]
	>=x11-libs/libXrandr-1.2[lib32?]
	>=gnome-base/gconf-2[lib32?]
	>=gnome-base/libgnomeui-2.6[lib32?]
	>=x11-libs/startup-notification-0.5[lib32?]
	>=dev-python/pygtk-2.8[lib32?]
	>=dev-python/pygobject-2.14[lib32?]
	>=dev-python/libgnome-python-2.22[lib32?]"
DEPEND="${RDEPEND}
	app-text/scrollkeeper
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9[lib32?]
	>=app-text/gnome-doc-utils-0.3.2[lib32?]
	doc? ( >=dev-util/gtk-doc-1.4 )
	~app-text/docbook-xml-dtd-4.1.2
	x11-proto/xproto
	>=x11-proto/randrproto-1.2
	gnome-base/gnome-common"
# Includes X11/Xatom.h in libgnome-desktop/gnome-bg.c which comes from xproto
# Includes X11/extensions/Xrandr.h that includes randr.h from randrproto (and
# eventually libXrandr shouldn't RDEPEND on randrproto)

DOCS="AUTHORS ChangeLog HACKING NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF} --with-gnome-distributor=Gentoo --disable-scrollkeeper"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Do not load background if not needed, bug #251350
	epatch "${FILESDIR}/${PN}-2.24.2-background.patch"

	# Broken intltool-0.40.6 used for 2.24.3, re-intltoolize
	intltoolize --force --automake --copy || die "intltoolize failed"
	eautomake
}

multilib-native_pkg_postinst_internal() {
	ewarn
	ewarn "If you are upgrading from <gnome-base/gnome-desktop-2.24, please"
	ewarn "make sure you run revdep-rebuild at the end of the upgrade."
}

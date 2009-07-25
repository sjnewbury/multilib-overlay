# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/epiphany/epiphany-2.20.3.ebuild,v 1.11 2008/03/17 14:03:39 armin76 Exp $

inherit gnome2 eutils multilib

DESCRIPTION="GNOME webbrowser based on the mozilla rendering engine"
HOMEPAGE="http://www.gnome.org/projects/epiphany/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="doc networkmanager python spell xulrunner"

# FIXME: add webkit/gecko switch possibility
# dang: *after* webkit actually works.

RDEPEND=">=dev-libs/glib-2.13.4
	>=x11-libs/gtk+-2.11.6
	>=dev-libs/libxml2-2.6.12
	>=dev-libs/libxslt-1.1.7
	>=gnome-base/libglade-2.3.1
	>=gnome-base/gnome-vfs-2.9.2
	>=gnome-base/libgnome-2.14
	>=gnome-base/libgnomeui-2.14
	>=gnome-base/gnome-desktop-2.9.91
	>=x11-libs/startup-notification-0.5
	>=dev-libs/dbus-glib-0.71
	>=gnome-base/gconf-2
	>=app-text/iso-codes-0.35
	networkmanager? ( net-misc/networkmanager )
	!xulrunner? ( =www-client/mozilla-firefox-2* )
	xulrunner? ( =net-libs/xulrunner-1.8* )
	python? (
		>=dev-lang/python-2.3
		>=dev-python/pygtk-2.7.1
		>=dev-python/gnome-python-2.6 )
	spell? ( app-text/enchant )
	x11-themes/gnome-icon-theme"

DEPEND="${RDEPEND}
	app-text/scrollkeeper
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.35
	>=app-text/gnome-doc-utils-0.3.2
	>=gnome-base/gnome-common-2.12.0
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-scrollkeeper
		--with-engine=mozilla
		$(use_enable networkmanager network-manager)
		$(use_enable spell spell-checker)
		$(use_enable python)"

	if use xulrunner; then
		G2CONF="${G2CONF} --with-gecko=xulrunner"
	else
		G2CONF="${G2CONF} --with-gecko=firefox"
	fi
}

src_unpack()
{
	gnome2_src_unpack

	epatch "${FILESDIR}/${P}-fix-de-docs-tests.patch"
	epatch "${FILESDIR}/${P}-gcc43.patch"
}

src_compile() {
	addpredict /usr/$(get_libdir)/mozilla-firefox/components/xpti.dat
	addpredict /usr/$(get_libdir)/mozilla-firefox/components/xpti.dat.tmp
	addpredict /usr/$(get_libdir)/mozilla-firefox/components/compreg.dat.tmp

	addpredict /usr/$(get_libdir)/xulrunner/components/xpti.dat
	addpredict /usr/$(get_libdir)/xulrunner/components/xpti.dat.tmp
	addpredict /usr/$(get_libdir)/xulrunner/components/compreg.dat.tmp

	addpredict /usr/$(get_libdir)/mozilla/components/xpti.dat
	addpredict /usr/$(get_libdir)/mozilla/components/xpti.dat.tmp

	gnome2_src_compile
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines/gtk-engines-2.16.1.ebuild,v 1.11 2009/04/28 11:07:00 armin76 Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="GTK+2 standard engines and themes"
HOMEPAGE="http://www.gtk.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="accessibility"

RDEPEND=">=x11-libs/gtk+-2.12[lib32?]"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.31
	>=dev-util/pkgconfig-0.9[lib32?]"

DOCS="AUTHORS ChangeLog NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="--enable-animation --enable-lua"
	use accessibility || G2CONF="${G2CONF} --disable-hc"
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines/gtk-engines-2.16.1.ebuild,v 1.7 2009/03/18 14:58:53 armin76 Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="GTK+2 standard engines and themes"
HOMEPAGE="http://www.gtk.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="2"
KEYWORDS=""
IUSE="accessibility"

RDEPEND=">=x11-libs/gtk+-2.12[lib32?]"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.31
	>=dev-util/pkgconfig-0.9"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	G2CONF="--enable-animation --enable-lua"
	use accessibility || G2CONF="${G2CONF} --disable-hc"
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgtop/libgtop-2.20.1.ebuild,v 1.9 2009/01/04 00:03:54 eva Exp $

inherit gnome2 multilib-native

DESCRIPTION="A library that provides top functionality to applications"
HOMEPAGE="http://www.gnome.org/"
LICENSE="GPL-2"

SLOT="2"
KEYWORDS="arm sh"
IUSE=""

RDEPEND=">=dev-libs/glib-2.6[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)]
	>=dev-util/intltool-0.35"

DOCS="AUTHORS ChangeLog NEWS README"

ml-native_pkg_setup() { :; }

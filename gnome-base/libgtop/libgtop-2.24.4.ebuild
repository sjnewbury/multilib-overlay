# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgtop/libgtop-2.24.4.ebuild,v 1.7 2009/04/12 20:46:30 bluebird Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="A library that provides top functionality to applications"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="alpha amd64 ~arm ~hppa ia64 ~mips ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE="debug"

RDEPEND=">=dev-libs/glib-2.6"
DEPEND="${RDEPEND}
		dev-util/pkgconfig[$(get_ml_usedeps)?]
		>=dev-util/intltool-0.35"

DOCS="AUTHORS ChangeLog NEWS README"

ml-native_pkg_setup() {
	G2CONF="${G2CONF} --disable-static"
}

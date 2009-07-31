# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgtop/libgtop-2.22.3.ebuild,v 1.8 2009/01/19 01:29:28 leio Exp $

inherit gnome2 multilib-native

DESCRIPTION="A library that provides top functionality to applications"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="alpha amd64 ~arm hppa ia64 ~mips ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE="debug"

RDEPEND=">=dev-libs/glib-2.6[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
		dev-util/pkgconfig[$(get_ml_usedeps)?]
		>=dev-util/intltool-0.35"

DOCS="AUTHORS ChangeLog NEWS README"

ml-native_pkg_setup() { :; }

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/libgnomecups/libgnomecups-0.2.3.ebuild,v 1.9 2009/04/14 11:52:50 armin76 Exp $

EAPI="2"

inherit autotools eutils gnome2 multilib-native

DESCRIPTION="GNOME cups library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=dev-libs/glib-2[$(get_ml_usedeps)?]
	>=net-print/cups-1.3.8[$(get_ml_usedeps)?]"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9[$(get_ml_usedeps)?]
	>=dev-util/intltool-0.28"

DOCS="AUTHORS ChangeLog NEWS"

ml-native_src_prepare() {
	epatch "${FILESDIR}"/enablenet.patch
}

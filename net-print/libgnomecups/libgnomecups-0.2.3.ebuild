# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/libgnomecups/libgnomecups-0.2.3.ebuild,v 1.8 2009/01/31 18:54:58 eva Exp $

EAPI="2"

inherit autotools eutils gnome2 multilib-native

DESCRIPTION="GNOME cups library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=dev-libs/glib-2[lib32?]
	>=net-print/cups-1.3.8[lib32?]"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.28"

DOCS="AUTHORS ChangeLog NEWS"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch "${FILESDIR}/enablenet.patch"
	sed -i -e "/^CUPS_.*/s:cups-config:\$CUPS_CONFIG:g" configure.in
	eautoreconf
}

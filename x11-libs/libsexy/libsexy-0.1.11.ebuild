# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libsexy/libsexy-0.1.11.ebuild,v 1.9 2008/10/11 23:53:13 eva Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="Sexy GTK+ Widgets"
HOMEPAGE="http://www.chipx86.com/wiki/Libsexy"
SRC_URI="http://releases.chipx86.com/${PN}/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.6[lib32?]
		 >=x11-libs/gtk+-2.6[lib32?]
		   dev-libs/libxml2[lib32?]
		 >=x11-libs/pango-1.4.0[lib32?]
		 >=app-text/iso-codes-0.49"
DEPEND="${RDEPEND}
		>=dev-lang/perl-5[lib32?]
		>=dev-util/pkgconfig-0.19[lib32?]
		doc? ( >=dev-util/gtk-doc-1.4 )"

DOCS="AUTHORS ChangeLog NEWS README"

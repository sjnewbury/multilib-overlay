# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-xfce/gtk-engines-xfce-2.6.0.ebuild,v 1.1 2009/03/10 13:55:18 angelos Exp $

EAPI="2"

MY_PN="gtk-xfce-engine"
inherit xfce4 multilib-native

XFCE_VERSION=4.6.0

xfce4_core

DESCRIPTION="GTK+ Xfce4 theme engine"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.6:2[lib32?]
	>=dev-libs/glib-2.6:2[lib32?]
	x11-libs/cairo[lib32?]
	x11-libs/pango[lib32?]"

DOCS="AUTHORS ChangeLog NEWS README"

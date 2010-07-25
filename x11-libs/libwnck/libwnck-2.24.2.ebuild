# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libwnck/libwnck-2.24.2.ebuild,v 1.9 2010/07/20 02:29:38 jer Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ia64 ~mips ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=x11-libs/gtk+-2.11.3[lib32?]
		 >=dev-libs/glib-2.13.0[lib32?]
		 >=x11-libs/startup-notification-0.4[lib32?]
		 x11-libs/libX11[lib32?]
		 x11-libs/libXres[lib32?]
		 x11-libs/libXext[lib32?]"
DEPEND="${RDEPEND}
		sys-devel/gettext[lib32?]
		>=dev-util/pkgconfig-0.9[lib32?]
		>=dev-util/intltool-0.40
		doc? ( >=dev-util/gtk-doc-1.9 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

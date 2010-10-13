# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libwnck/libwnck-2.30.5.ebuild,v 1.1 2010/09/27 21:59:49 eva Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2 multilib-native

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"

IUSE="doc +introspection startup-notification"

RDEPEND=">=x11-libs/gtk+-2.19.7[introspection?,lib32?]
	>=dev-libs/glib-2.16.0[lib32?]
	x11-libs/libX11[lib32?]
	x11-libs/libXres[lib32?]
	x11-libs/libXext[lib32?]
	introspection? ( >=dev-libs/gobject-introspection-0.6.14[lib32?] )
	startup-notification? ( >=x11-libs/startup-notification-0.4[lib32?] )"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.40
	doc? ( >=dev-util/gtk-doc-1.9 )
	x86-interix? ( sys-libs/itx-bind )"
# eautoreconf needs
#	dev-util/gtk-doc-am
#	gnome-base/gnome-common

DOCS="AUTHORS ChangeLog HACKING NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-static
		$(use_enable introspection)
		$(use_enable startup-notification)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	if use x86-interix; then
		# activate the itx-bind package...
		append-flags "-I${EPREFIX}/usr/include/bind"
		append-ldflags "-L${EPREFIX}/usr/lib/bind"
	fi
}

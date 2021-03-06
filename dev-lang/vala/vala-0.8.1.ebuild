# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/vala/vala-0.8.1.ebuild,v 1.10 2011/02/20 15:12:29 xarthisius Exp $

EAPI=3
GCONF_DEBUG=no

inherit gnome2 multilib-native

DESCRIPTION="Vala - Compiler for the GObject type system"
HOMEPAGE="http://live.gnome.org/Vala"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ppc ~ppc64 ~sh ~sparc x86"
IUSE="test +vapigen"

RDEPEND=">=dev-libs/glib-2.14[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/flex[lib32?]
	|| ( sys-devel/bison dev-util/byacc dev-util/yacc )
	dev-util/pkgconfig[lib32?]
	dev-libs/libxslt[lib32?]
	test? ( dev-libs/dbus-glib[lib32?] )"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		$(use_enable vapigen)"
	DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README"
}

multilib-native_src_install_internal() {
	gnome2_src_install
	# dconf ships it for itself, this is already fixed on newer vala
	rm -f "${ED}"/usr/share/vala/vapi/dconf.vapi
}

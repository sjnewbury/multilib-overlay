# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/vala/vala-0.7.9.ebuild,v 1.2 2010/01/01 12:47:18 armin76 Exp $

EAPI=2
GCONF_DEBUG=no
inherit gnome2 multilib-native

DESCRIPTION="Vala - Compiler for the GObject type system"
HOMEPAGE="http://live.gnome.org/Vala"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~sparc ~x86"
IUSE="test +vapigen +coverage"

#FIXME: flex and bison are in "base" profile,
# so why put them into DEPEND ?
RDEPEND=">=dev-libs/glib-2.12"
DEPEND="${RDEPEND}
	sys-devel/flex[lib32?]
	|| ( sys-devel/bison dev-util/byacc dev-util/yacc )
	dev-util/pkgconfig[lib32?]
	dev-libs/libxslt[lib32?]
	test? ( dev-libs/dbus-glib[lib32?] )"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		$(use_enable vapigen)
		$(use_enable coverage)"
	DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README"
}

multilib-native_src_install_internal() {
	gnome2_src_install
	prep_ml_binaries /usr/bin/vala-gen-introspect \
			 /usr/bin/valac \
			 /usr/bin/vapicheck \
			 /usr/bin/vapigen
}

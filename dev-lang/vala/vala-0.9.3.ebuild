# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/vala/vala-0.9.3.ebuild,v 1.2 2010/12/20 22:37:26 eva Exp $

EAPI=2
GCONF_DEBUG=no

inherit gnome2 multilib-native

DESCRIPTION="Vala - Compiler for the GObject type system"
HOMEPAGE="http://live.gnome.org/Vala"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
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

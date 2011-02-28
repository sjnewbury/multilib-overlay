# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/vala/vala-0.11.6.ebuild,v 1.1 2011/02/14 22:40:47 eva Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit gnome2 multilib-native

DESCRIPTION="Vala - Compiler for the GObject type system"
HOMEPAGE="http://live.gnome.org/Vala"

LICENSE="LGPL-2.1"
SLOT="0.12"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="test +vapigen"

RDEPEND=">=dev-libs/glib-2.16:2[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/flex[lib32?]
	|| ( sys-devel/bison dev-util/byacc dev-util/yacc )
	dev-util/pkgconfig[lib32?]
	dev-libs/libxslt[lib32?]
	test? (
		dev-libs/dbus-glib[lib32?]
		>=dev-libs/glib-2.26[lib32?] )"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-unversioned
		$(use_enable vapigen)"
	DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README"
}

multilib-native_src_install_internal() {
	gnome2_src_install
	mv "${ED}"/usr/share/aclocal/vala.m4 \
		"${ED}"/usr/share/aclocal/vala-${SLOT/./-}.m4 || die "failed to move vala m4 macro"
	find "${ED}" -name "*.la" -delete || die "la file removal failed"
}

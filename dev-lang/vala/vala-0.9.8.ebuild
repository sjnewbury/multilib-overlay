# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/vala/vala-0.9.8.ebuild,v 1.2 2010/09/19 17:28:34 eva Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2 multilib-native

DESCRIPTION="Vala - Compiler for the GObject type system"
HOMEPAGE="http://live.gnome.org/Vala"

LICENSE="LGPL-2.1"
SLOT="0.10"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="test +vapigen coverage"

RDEPEND=">=dev-libs/glib-2.14[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/flex[lib32?]
	|| ( sys-devel/bison dev-util/byacc dev-util/yacc )
	dev-util/pkgconfig[lib32?]
	dev-libs/libxslt[lib32?]
	test? ( dev-libs/dbus-glib[lib32?] )"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-unversioned
		$(use_enable vapigen)
		$(use_enable coverage)"
	DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README"

	if use coverage && has ccache ${FEATURES}; then
		ewarn "USE=coverage does not work well with ccache; valac and libvala"
		ewarn "built with ccache and USE=coverage create temporary files inside"
		ewarn "CCACHE_DIR and mess with ccache's working, as well as causing"
		ewarn "sandbox violations when used to compile other packages."
		ewarn "It is STRONGLY recommended that you disable one of them."
	fi
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines/gtk-engines-2.18.2-r1.ebuild,v 1.3 2009/09/03 10:46:19 mrpouet Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools eutils gnome2 multilib-native

DESCRIPTION="GTK+2 standard engines and themes"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="accessibility lua"

RDEPEND=">=x11-libs/gtk+-2.12[lib32?]
	lua? ( dev-lang/lua[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.31
	>=dev-util/pkgconfig-0.9[lib32?]"

DOCS="AUTHORS ChangeLog NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF} --enable-animation $(use_enable lua) $(use_with lua system-lua)"
	use accessibility || G2CONF="${G2CONF} --disable-hc"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Don't use liblua embedded version, use system lib instead
	# fix bug #255773, import from upstream bug #593674, FIXED VERSION
	# (patch commented out)
	epatch "${FILESDIR}"/${P}-system-lua.patch
	intltoolize --automake --copy --force || die "intltoolize failed"
	eautoreconf
}

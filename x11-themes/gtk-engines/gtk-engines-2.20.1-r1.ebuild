# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines/gtk-engines-2.20.1-r1.ebuild,v 1.4 2010/08/05 16:32:01 jer Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2 eutils multilib-native

DESCRIPTION="GTK+2 standard engines and themes"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~x64-solaris ~x86-solaris"
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

	# Upstream bug 616124: drop xfce workaround that will break
	epatch "${FILESDIR}/${P}-xfce-workaround.patch"

	# Fix evolution table header workaround for new evo versions
	epatch "${FILESDIR}/${P}-evolution-workaround.patch"
}

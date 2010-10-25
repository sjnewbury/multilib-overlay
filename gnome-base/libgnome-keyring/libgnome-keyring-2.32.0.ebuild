# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnome-keyring/libgnome-keyring-2.32.0.ebuild,v 1.3 2010/10/19 18:44:45 pacho Exp $

EAPI="3"
GCONF_DEBUG="yes"

inherit gnome2 multilib-native

DESCRIPTION="Compatibility library for accessing secrets"
HOMEPAGE="http://live.gnome.org/GnomeKeyring"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-linux"
IUSE="debug doc test"

RDEPEND=">=sys-apps/dbus-1.0[lib32?]
	gnome-base/gconf[lib32?]
	>=gnome-base/gnome-keyring-2.29[test?,lib32?]
	!<gnome-base/gnome-keyring-2.29[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9[lib32?]
	doc? ( >=dev-util/gtk-doc-1.9 )"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		$(use_enable debug)
		$(use_enable test tests)"
	DOCS="AUTHORS ChangeLog NEWS README"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Remove silly CFLAGS
	sed 's:CFLAGS="$CFLAGS -Werror:CFLAGS="$CFLAGS:' \
		-i configure.in configure || die "sed failed"

	# Remove DISABLE_DEPRECATED flags
	sed -e '/-D[A-Z_]*DISABLE_DEPRECATED/d' \
		-i configure.in configure || die "sed 2 failed"
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	emake check || die "tests failed"
}

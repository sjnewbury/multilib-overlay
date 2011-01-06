# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-keyring/gnome-keyring-2.32.1.ebuild,v 1.4 2011/01/02 21:32:23 mr_bones_ Exp $

EAPI="3"
GCONF_DEBUG="yes"

inherit gnome2 multilib pam virtualx multilib-native

DESCRIPTION="Password and keyring managing daemon"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="debug doc pam test"
# USE=valgrind is probably not a good idea for the tree

RDEPEND=">=dev-libs/glib-2.25:2[lib32?]
	>=x11-libs/gtk+-2.20:2[lib32?]
	gnome-base/gconf[lib32?]
	>=sys-apps/dbus-1.0[lib32?]
	pam? ( virtual/pam[lib32?] )
	>=dev-libs/libgcrypt-1.2.2[lib32?]
	>=dev-libs/libtasn1-1[lib32?]"
#	valgrind? ( dev-util/valgrind )"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9[lib32?]
	doc? ( >=dev-util/gtk-doc-1.9 )"
PDEPEND="gnome-base/libgnome-keyring"
# eautoreconf needs:
#	>=dev-util/gtk-doc-am-1.9

DOCS="AUTHORS ChangeLog NEWS README"

# tests fail in several ways, they should be fixed in the next cycle (bug #340283),
# revisit then.
RESTRICT="test"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		$(use_enable debug)
		$(use_enable test tests)
		$(use_enable pam)
		$(use_with pam pam-dir $(getpam_mod_dir))
		--with-root-certs=/usr/share/ca-certificates/
		--enable-acl-prompts
		--enable-ssh-agent
		--enable-gpg-agent
		--with-gtk=2.0"
#		$(use_enable valgrind)
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

multilib-native_src_install_internal() {
	gnome2_src_install
	if use pam; then
		find "${ED}"/$(get_libdir)/security -name "*.la" -delete \
			|| die "la file removal failed"
	fi
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check || die "emake check failed!"
}

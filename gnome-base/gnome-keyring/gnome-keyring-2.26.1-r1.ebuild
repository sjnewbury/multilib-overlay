# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-keyring/gnome-keyring-2.26.1-r1.ebuild,v 1.2 2009/06/30 07:50:28 aballier Exp $

EAPI="2"

inherit gnome2 pam virtualx eutils autotools multilib-native

DESCRIPTION="Password and keyring managing daemon"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="debug doc hal pam test"
# USE=valgrind is probably not a good idea for the tree

RDEPEND=">=dev-libs/glib-2.16[lib32?]
	>=x11-libs/gtk+-2.6[lib32?]
	gnome-base/gconf[lib32?]
	>=sys-apps/dbus-1.0[lib32?]
	hal? ( >=sys-apps/hal-0.5.7[lib32?] )
	pam? ( virtual/pam )
	pam? ( sys-libs/pam[lib32?] )
	>=dev-libs/libgcrypt-1.2.2[lib32?]
	>=dev-libs/libtasn1-1[lib32?]"
#	valgrind? ( dev-util/valgrind )"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9[lib32?]
	doc? ( >=dev-util/gtk-doc-1.9 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

ml-native_pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable debug)
		$(use_enable hal)
		$(use_enable test tests)
		$(use_enable pam)
		$(use_with pam pam-dir $(getpam_mod_dir))
		--with-root-certs=/usr/share/ca-certificates/
		--enable-acl-prompts
		--enable-ssh-agent"
#		$(use_enable valgrind)
}

ml-native_src_prepare() {
	gnome2_src_prepare

	# Remove silly CFLAGS
	sed 's:CFLAGS="$CFLAGS -Werror:CFLAGS="$CFLAGS:' \
		-i configure.in configure || die "sed failed"

	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in || die "sed failed"

	# Detect where dlopen functions are rather than hardcoding -ldl
	# Fixes build on BSD
	# Bug #271359
	# Gnome bug #584307
	epatch "${FILESDIR}/${P}-dlopen.patch"
	eautoreconf

}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check || die "emake check failed!"

	Xemake -C tests run || die "running tests failed!"
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-keyring/gnome-keyring-2.22.3-r2.ebuild,v 1.6 2010/07/20 01:50:46 jer Exp $

EAPI="2"

inherit gnome2 eutils pam autotools multilib-native

DESCRIPTION="Password and keyring managing daemon"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ~ia64 ~mips ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd"
IUSE="debug doc hal pam test"

RDEPEND=">=dev-libs/glib-2.8[lib32?]
	 >=x11-libs/gtk+-2.6[lib32?]
	 gnome-base/gconf[lib32?]
	 >=sys-apps/dbus-1.0[lib32?]
	 hal? ( >=sys-apps/hal-0.5.7[lib32?] )
	 pam? ( virtual/pam[lib32?] )
	 >=dev-libs/libgcrypt-1.2.2[lib32?]
	 >=dev-libs/libtasn1-1[lib32?]"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9[lib32?]
	dev-util/gtk-doc-am
	doc? ( dev-util/gtk-doc )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		$(use_enable debug)
		$(use_enable hal)
		$(use_enable test tests)
		$(use_enable pam)
		$(use_with pam pam-dir $(getpam_mod_dir))
		--with-root-certs=/usr/share/ca-certificates/"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Backport from trunk for fixing upstream bug #511285, bug #238098
	epatch "${FILESDIR}/${P}-warnings.patch"

	# Fix configure with recent libtasn1, bug #266554
	epatch "${FILESDIR}/${P}-pkg-libtasn1.patch"

	# Makes the installed public headers includeable in C++ code, such as webkit-gtk
	epatch "${FILESDIR}/${P}-headers-fix-for-cxx.patch"

	intltoolize --force --copy --automake || die "inltoolize failed"
	eautoreconf
}

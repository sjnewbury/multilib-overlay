# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libsoup-gnome/libsoup-gnome-2.30.2.ebuild,v 1.10 2010/10/17 14:48:37 armin76 Exp $

EAPI="2"

inherit autotools eutils gnome2 multilib-native

MY_PN=${PN/-gnome}
MY_P=${MY_PN}-${PV}

DESCRIPTION="GNOME plugin for libsoup"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="${SRC_URI//-gnome}
	mirror://gentoo/${MY_PN}-2.30.1-build-gir-patches.tar.bz2"

LICENSE="LGPL-2"
SLOT="2.4"
KEYWORDS="alpha amd64 arm ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~amd64-linux ~x86-solaris"
# Do NOT build with --disable-debug/--enable-debug=no - gnome2.eclass takes care of that
IUSE="debug doc +introspection"

RDEPEND="~net-libs/libsoup-${PV}[lib32?]
	|| ( gnome-base/libgnome-keyring[lib32?] <gnome-base/gnome-keyring-2.29.4[lib32?] )
	net-libs/libproxy[lib32?]
	>=gnome-base/gconf-2[lib32?]
	dev-db/sqlite:3[lib32?]
	introspection? ( >=dev-libs/gobject-introspection-0.6.7 )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/gtk-doc-am-1.10
	doc? ( >=dev-util/gtk-doc-1.10 )"

S=${WORKDIR}/${MY_P}

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-static
		$(use_enable introspection)
		--with-libsoup-system
		--with-gnome"
	DOCS="AUTHORS NEWS README"
}

multilib-native_src_configure_internal() {
	# FIXME: we need addpredict to workaround bug #324779 until
	# root cause (bug #249496) is solved
	addpredict /usr/share/snmp/mibs/.index
	gnome2_src_configure
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix test to follow POSIX (for x86-fbsd)
	# No patch to prevent having to eautoreconf
	sed -e 's/\(test.*\)==/\1=/g' -i configure.ac configure || die "sed failed"

	# Unconditionally apply so the next patch applies
	epatch "${WORKDIR}/${MY_PN}-2.30.1-build-gir-1.patch"
	epatch "${WORKDIR}/${MY_PN}-2.30.1-build-gir-2.patch"

	# Use lib present on the system
	epatch "${FILESDIR}"/${PN}-2.30.1-system-lib.patch
	eautoreconf
}

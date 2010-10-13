# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libart_lgpl/libart_lgpl-2.3.21-r1.ebuild,v 1.9 2010/10/07 22:01:39 ssuominen Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit autotools eutils gnome2 multilib-native

DESCRIPTION="a LGPL version of libart"
HOMEPAGE="http://www.levien.com/libart"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND="dev-util/pkgconfig[lib32?]"

# The provided tests are interactive only
RESTRICT="test"

DOCS="AUTHORS ChangeLog NEWS README"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF} --disable-static"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix crosscompiling, bug #185684
	rm "${S}"/art_config.h
	epatch "${FILESDIR}"/${PN}-2.3.21-crosscompile.patch

	# Do not build tests if not required
	epatch "${FILESDIR}"/${PN}-2.3.21-no-test-build.patch

	eautoreconf
}

multilib-native_src_install_internal() {
	multilib-native_check_inherited_funcs src_install
	prep_ml_binaries /usr/bin/libart2-config
}

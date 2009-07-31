# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libart_lgpl/libart_lgpl-2.3.20.ebuild,v 1.8 2008/12/07 11:53:25 vapier Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

DESCRIPTION="a LGPL version of libart"
HOMEPAGE="http://www.levien.com/libart"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

DEPEND="dev-util/pkgconfig[lib32?]"
RDEPEND=""

DOCS="AUTHORS ChangeLog NEWS README"

src_unpack() {
	gnome2_src_unpack

	# Fix crosscompiling; bug #185684
	epatch "${FILESDIR}"/${PN}-2.3.19-crosscompile.patch
}

ml-native_src_install() {
	multilib-native_check_inherited_funcs src_install
	prep_ml_binaries /usr/bin/libart2-config 
}

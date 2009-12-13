# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libfontenc/libfontenc-1.0.4.ebuild,v 1.13 2009/05/08 21:11:23 ssuominen Exp $

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org fontenc library"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="sys-libs/zlib[lib32?]"
DEPEND="${RDEPEND}
	x11-proto/xproto"

multilib-native_pkg_setup_internal() {
	CONFIGURE_OPTIONS="--with-encodingsdir=/usr/share/fonts/encodings"
}

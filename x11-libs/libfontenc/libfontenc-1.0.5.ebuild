# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libfontenc/libfontenc-1.0.5.ebuild,v 1.3 2009/12/10 19:26:29 fauli Exp $

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular multilib-native

DESCRIPTION="X.Org fontenc library"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}
	x11-proto/xproto"

multilib-native_pkg_setup_internal() {
	CONFIGURE_OPTIONS="--with-encodingsdir=/usr/share/fonts/encodings"
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/imake/imake-1.0.2.ebuild,v 1.13 2010/10/17 03:27:47 leio Exp $

EAPI="2"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular multilib-native

DESCRIPTION="C preprocessor interface to the make utility"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="x11-misc/xorg-cf-files[lib32?]
	!x11-misc/xmkmf"
DEPEND="${RDEPEND}
	x11-proto/xproto"

multilib-native_src_install_internal() {
	multilib-native_check_inherited_funcs src_install
	prep_ml_binaries /usr/bin/xmkmf /usr/bin/imake
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/imake/imake-1.0.3.ebuild,v 1.9 2010/09/28 13:34:46 ssuominen Exp $

EAPI=3

XORG_STATIC=no
inherit xorg-2 multilib-native

DESCRIPTION="C preprocessor interface to the make utility"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ~ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-misc/xorg-cf-files[lib32?]"
DEPEND="${RDEPEND}
	x11-proto/xproto"

multilib-native_src_prepare_internal() {
	# don't use Sun compilers on Solaris, we want GCC from prefix
	sed -i -e "1s/^.*$/#if defined(sun)\n# undef sun\n#endif/" \
		imake.c imakemdep.h
	xorg-2_src_prepare
}

multilib-native_src_install_internal() {
	multilib-native_check_inherited_funcs src_install
	prep_ml_binaries /usr/bin/xmkmf /usr/bin/imake
}

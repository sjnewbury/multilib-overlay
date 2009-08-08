# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/imake/imake-1.0.2.ebuild,v 1.12 2009/05/05 17:34:08 ssuominen Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="C preprocessor interface to the make utility"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND="x11-misc/xorg-cf-files[lib32?]
	!x11-misc/xmkmf"
DEPEND="${RDEPEND}
	x11-proto/xproto"

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	use lib32 && sed -i -e 's/imake \$imake_defines/imake-'"$ABI"' \$imake_defines/g' \
		"${D}/usr/bin/xmkmf"
	prep_ml_binaries /usr/bin/xmkmf /usr/bin/imake
}

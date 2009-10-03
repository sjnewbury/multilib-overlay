# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libSM/libSM-1.1.1.ebuild,v 1.5 2009/09/30 19:55:38 ssuominen Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org SM library"

KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="ipv6 +uuid elibc_FreeBSD"

RDEPEND="x11-libs/libICE[lib32?]
	x11-libs/xtrans
	x11-proto/xproto
	uuid? (
	  !elibc_FreeBSD? (
		|| ( >=sys-apps/util-linux-2.16[lib32?] <sys-libs/e2fsprogs-libs-1.41.8[lib32?] )
	  )
	)"
DEPEND="${RDEPEND}"

pkg_setup() {
	CONFIGURE_OPTIONS="$(use_enable ipv6) $(use_with uuid libuuid)"
	# do not use uuid even if available in libc (like on FreeBSD)
	use uuid || export ac_cv_func_uuid_create=no
}

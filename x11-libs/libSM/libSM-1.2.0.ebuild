# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libSM/libSM-1.2.0.ebuild,v 1.8 2011/01/27 16:48:02 darkside Exp $

EAPI=3
inherit xorg-2 multilib-native

DESCRIPTION="X.Org SM library"

KEYWORDS="~alpha amd64 arm hppa ~ia64 ~mips ~ppc ppc64 ~s390 ~sh ~sparc x86 ~ppc-aix ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="doc ipv6 +uuid"

RDEPEND="x11-libs/libICE[lib32?]
	x11-libs/xtrans[lib32?]
	x11-proto/xproto
	!elibc_FreeBSD? ( !elibc_IRIX? ( !elibc_SunOS? (
		uuid? ( >=sys-apps/util-linux-2.16[lib32?] )
	) ) )"
DEPEND="${RDEPEND}
	doc? ( app-text/xmlto )"

multilib-native_pkg_setup_internal() {
	xorg-2_pkg_setup

	CONFIGURE_OPTIONS="$(use_enable ipv6)
		$(use_enable doc docs)
		$(use_with doc xmlto)
		$(use_with uuid libuuid)
		--without-fop"
	# do not use uuid even if available in libc (like on FreeBSD)
	use uuid || export ac_cv_func_uuid_create=no
	# solaris hack
	if use uuid &&
		[[ ${CHOST} == *-solaris* ]] &&
		[[ ! -d ${EROOT}/usr/include/uuid ]] &&
		[[ -d ${ROOT}/usr/include/uuid ]]
	then
		# ${ROOT} is proper here
		export LIBUUID_CFLAGS="-I${ROOT}/usr/include/uuid"
		export LIBUUID_LIBS="-luuid"
	fi
}

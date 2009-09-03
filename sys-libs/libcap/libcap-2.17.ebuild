# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libcap/libcap-2.17.ebuild,v 1.1 2009/08/31 00:20:00 vapier Exp $

EAPI="2"

inherit eutils multilib toolchain-funcs pam multilib-native

DESCRIPTION="POSIX 1003.1e capabilities"
HOMEPAGE="http://www.friedhoff.org/posixfilecaps.html"
SRC_URI="mirror://kernel/linux/libs/security/linux-privs/libcap${PV:0:1}/${P}.tar.bz2"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="pam"

RDEPEND="sys-apps/attr[lib32?]
	pam? ( virtual/pam )"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/2.16/*.patch
	sed -i -e '/cap_setfcap.*morgan/s:^:#:' pam_cap/capability.conf
	sed -i \
		-e "/^PAM_CAP/s:=.*:=$(use pam && echo yes || echo no):" \
		-e '/^DYNAMIC/s:=.*:=yes:' \
		-e "/^lib=/s:=.*:=$(get_libdir):" \
		Make.Rules
}

multilib-native_src_compile_internal() {
	[[ -z ${EMULTILIB_PKG} ]] && tc-export BUILD_CC CC AR RANLIB
	emake lib=$(get_libdir) || die
}

multilib-native_src_install_internal() {
	emake install lib=$(get_libdir) DESTDIR="${D}" || die

	gen_usr_ldscript libcap.so
	mv "${D}"/$(get_libdir)/libcap.a "${D}"/usr/$(get_libdir)/ || die

	dopammod pam_cap/pam_cap.so
	dopamsecurity '' pam_cap/capability.conf

	dodoc CHANGELOG README doc/capability.notes
}

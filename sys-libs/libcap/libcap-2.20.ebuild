# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libcap/libcap-2.20.ebuild,v 1.1 2011/01/25 21:00:58 vapier Exp $

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
	pam? ( virtual/pam[lib32?] )"
DEPEND="${RDEPEND}
	sys-kernel/linux-headers"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-2.20-build-system-fixes.patch
	epatch "${FILESDIR}"/${PN}-2.20-ignore-RAISE_SETFCAP-install-failures.patch
	sed -i \
		-e "/^PAM_CAP/s:=.*:=$(use pam && echo yes || echo no):" \
		-e '/^DYNAMIC/s:=.*:=yes:' \
		-e "/^lib=/s:=.*:=/usr/$(get_libdir):" \
		Make.Rules
}

multilib-native_src_compile_internal() {
	tc-export BUILD_CC CC AR RANLIB
	emake || die
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die

	gen_usr_ldscript -a cap

	dopammod pam_cap/pam_cap.so
	dopamsecurity '' pam_cap/capability.conf

	dodoc CHANGELOG README doc/capability.notes
}

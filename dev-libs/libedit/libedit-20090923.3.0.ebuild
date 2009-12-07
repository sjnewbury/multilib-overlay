# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libedit/libedit-20090923.3.0.ebuild,v 1.4 2009/11/23 13:23:49 maekke Exp $

inherit eutils toolchain-funcs versionator multilib-native

MY_PV=$(get_major_version)-$(get_after_major_version)
MY_P=${PN}-${MY_PV}

DESCRIPTION="BSD replacement for libreadline."
HOMEPAGE="http://www.thrysoee.dk/editline/"
SRC_URI="http://www.thrysoee.dk/editline/${MY_P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm ~hppa ~ia64 ~m68k ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

DEPEND="sys-libs/ncurses
	!<=sys-freebsd/freebsd-lib-6.2_rc1"

RDEPEND=${DEPEND}

S="${WORKDIR}/${MY_P}"

multilib-native_src_unpack_internal() {
	unpack ${A}

	cd "${S}"

	epatch "${FILESDIR}"/${PN}-20090111-3.0-weak_reference.patch
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install

	gen_usr_ldscript -a edit
}

# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libical/libical-0.26.7.ebuild,v 1.9 2007/10/06 04:53:20 tgall Exp $

EAPI="2"

inherit versionator multilib-native

MY_VER=$(replace_version_separator 2 -)

DESCRIPTION="libical is an implementation of basic iCAL protocols"
HOMEPAGE="http://www.aurore.net/projects/libical/"
SRC_URI="http://www.aurore.net/projects/libical/${PN}-${MY_VER}.aurore.tar.bz2"
SLOT="0"
LICENSE="|| ( MPL-1.1 LGPL-2 )"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/bison-1.875d
	>=sys-devel/flex-2.5.4a-r6[lib32?]
	>=sys-apps/gawk-3.1.4-r4
	>=dev-lang/perl-5.8.7-r3[lib32?]"

S="${WORKDIR}"/libical-${PV%.*}

multilib-native_src_configure_internal() {
	# Fix 66377
	LDFLAGS="${LDFLAGS} -lpthread" econf || die "Configuration failed"
}

multilib-native_src_install_internal() {
	einstall || die "Installation failed..."
}

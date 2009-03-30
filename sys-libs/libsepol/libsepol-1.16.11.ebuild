# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libsepol/libsepol-1.16.11.ebuild,v 1.3 2008/09/10 17:34:19 pebenito Exp $

EAPI="2"

IUSE=""

inherit multilib eutils multilib-native

#BUGFIX_PATCH="${FILESDIR}/libsepol-1.16.2.diff"

DESCRIPTION="SELinux binary policy representation library"
HOMEPAGE="http://www.nsa.gov/selinux"
SRC_URI="http://www.nsa.gov/selinux/archives/${P}.tgz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 mips ppc sparc x86"

DEPEND="virtual/libc"

# tests are not meant to be run outside of the
# full SELinux userland repo
RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"

	[ ! -z "$BUGFIX_PATCH" ] && epatch "${BUGFIX_PATCH}"
}

multilib-native_src_prepare_internal() {
	# fix up paths for multilib
	sed -i -e "/^LIBDIR/s/lib/$(get_libdir)/" src/Makefile \
		|| die "Fix for multilib LIBDIR failed."
	sed -i -e "/^SHLIBDIR/s/lib/$(get_libdir)/" src/Makefile \
		|| die "Fix for multilib SHLIBDIR failed."
}

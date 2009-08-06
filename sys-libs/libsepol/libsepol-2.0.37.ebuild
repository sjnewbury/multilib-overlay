# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libsepol/libsepol-2.0.37.ebuild,v 1.1 2009/08/02 01:12:10 pebenito Exp $

EAPI="2"

IUSE=""

inherit multilib eutils multilib-native

#BUGFIX_PATCH="${FILESDIR}/libsepol-2.0.32-expand_rule.diff"

DESCRIPTION="SELinux binary policy representation library"
HOMEPAGE="http://userspace.selinuxproject.org"
SRC_URI="http://userspace.selinuxproject.org/releases/current/devel/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

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
	sed -i -e "/^LIBDIR/s/lib/$(get_libdir)/" "${S}"/src/Makefile \
		|| die "Fix for multilib LIBDIR failed."
	sed -i -e "/^SHLIBDIR/s/lib/$(get_libdir)/" "${S}"/src/Makefile \
		|| die "Fix for multilib SHLIBDIR failed."

	# environmental variable clash with multilib-native.eclass
	sed -i -e "s/LIBDIR/LIB__DIR/g" "${S}"/src/Makefile \
		|| die "Fix for multilib LIBDIR => LIB__DIR failed."
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libsepol/libsepol-2.0.32.ebuild,v 1.3 2009/09/23 21:16:53 patrick Exp $

IUSE=""

inherit multilib eutils multilib-native

BUGFIX_PATCH="${FILESDIR}/libsepol-2.0.32-expand_rule.diff"

DESCRIPTION="SELinux binary policy representation library"
HOMEPAGE="http://userspace.selinuxproject.org"
SRC_URI="http://userspace.selinuxproject.org/releases/current/devel/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

DEPEND=""

# tests are not meant to be run outside of the
# full SELinux userland repo
RESTRICT="test"

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"

	[ ! -z "$BUGFIX_PATCH" ] && epatch "${BUGFIX_PATCH}"

	# fix up paths for multilib
	sed -i -e "/^LIBDIR/s/lib/$(get_libdir)/" src/Makefile \
		|| die "Fix for multilib LIBDIR failed."
	sed -i -e "/^SHLIBDIR/s/lib/$(get_libdir)/" src/Makefile \
		|| die "Fix for multilib SHLIBDIR failed."
}

multilib-native_src_compile_internal() {
	emake || die
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install
}

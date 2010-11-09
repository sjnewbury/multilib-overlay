# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXi/libXi-1.3.1.ebuild,v 1.12 2010/11/01 14:27:59 scarabeus Exp $

EAPI=3
XORG_EAUTORECONF="yes"
inherit xorg-2 multilib-native

DESCRIPTION="X.Org Xi library"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="doc"

RDEPEND="
	>=x11-libs/libX11-1.3[lib32?]
	>=x11-libs/libXext-1.1[lib32?]
	>=x11-proto/inputproto-2.0
	>=x11-proto/xproto-7.0.16
"
DEPEND="${RDEPEND}
	doc? (
		>=app-text/asciidoc-8.5.1
		app-text/xmlto
	)
"

PATCHES=( "${FILESDIR}/${PV}-0001-Add-configure-switch-for-manpages-regenerating.patch" )

multilib-native_pkg_setup_internal() {
	xorg-2_pkg_setup
	CONFIGURE_OPTIONS="
		$(use_with doc manpages)
	"
}

multilib-native_pkg_postinst_internal() {
	xorg-2_pkg_postinst

	ewarn "Some special keys and keyboard layouts may stop working."
	ewarn "To fix them, recompile xorg-server."
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libICE/libICE-1.0.6.ebuild,v 1.10 2010/01/19 20:03:16 armin76 Exp $

EAPI="2"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular multilib-native

DESCRIPTION="X.Org ICE library"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="ipv6"

RDEPEND="x11-libs/xtrans[lib32?]
	x11-proto/xproto"
DEPEND="${RDEPEND}"

multilib-native_pkg_setup_internal() {
	CONFIGURE_OPTIONS="$(use_enable ipv6)"
}

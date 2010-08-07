# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXext/libXext-1.1.1.ebuild,v 1.11 2010/08/02 18:23:14 armin76 Exp $

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xext library"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~x86-fbsd ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

COMMON_DEPEND=">=x11-libs/libX11-1.1.99.1[lib32?]"
RDEPEND="${COMMON_DEPEND}
	!<x11-proto/xextproto-7.1.1"
DEPEND="${COMMON_DEPEND}
	>=x11-proto/xextproto-7.0.99.2
	>=x11-proto/xproto-7.0.13"

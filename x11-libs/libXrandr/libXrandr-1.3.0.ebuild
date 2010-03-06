# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXrandr/libXrandr-1.3.0.ebuild,v 1.12 2010/01/15 21:51:06 fauli Exp $

EAPI="2"

inherit x-modular multilib-native

DESCRIPTION="X.Org Xrandr library"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXext[lib32?]
	x11-libs/libXrender[lib32?]
	>=x11-proto/randrproto-1.3
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/renderproto
	x11-proto/xextproto"

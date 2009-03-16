# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXcursor/libXcursor-1.1.9.ebuild,v 1.8 2008/01/13 09:23:20 vapier Exp $

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

EAPI="2"

XMODULAR_MULTILIB="yes"
inherit x-modular multilib-xlibs

DESCRIPTION="X.Org Xcursor library"

KEYWORDS="alpha amd64 arm ~hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"

RDEPEND="x11-libs/libXrender[lib32?]
	x11-libs/libXfixes[lib32?]
	x11-libs/libX11[lib32?]
	x11-proto/xproto"
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="--with-icondir=/usr/share/cursors/xorg-x11
	--with-cursorpath=~/.cursors:~/.icons:/usr/local/share/cursors/xorg-x11:/usr/local/share/cursors:/usr/local/share/icons:/usr/local/share/pixmaps:/usr/share/cursors/xorg-x11:/usr/share/cursors:/usr/share/pixmaps/xorg-x11:/usr/share/icons:/usr/share/pixmaps"

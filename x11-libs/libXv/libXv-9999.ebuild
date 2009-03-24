# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXv/libXv-1.0.4.ebuild,v 1.1 2008/03/18 04:15:55 dberkholz Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-xlibs

DESCRIPTION="X.Org Xv library"

KEYWORDS=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXext[lib32?]
	x11-proto/videoproto
	x11-proto/xproto"
DEPEND="${RDEPEND}"

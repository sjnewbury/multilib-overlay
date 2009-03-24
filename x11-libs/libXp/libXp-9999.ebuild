# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXp/libXp-1.0.0.ebuild,v 1.16 2007/02/04 18:25:36 joshuabaergen Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

EAPI="2"

inherit x-modular multilib-xlibs

DESCRIPTION="X.Org Xp library"

KEYWORDS=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXext[lib32?]
	x11-libs/libXau[lib32?]
	x11-proto/printproto"
DEPEND="${RDEPEND}"

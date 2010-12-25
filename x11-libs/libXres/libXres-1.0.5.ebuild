# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXres/libXres-1.0.5.ebuild,v 1.4 2010/12/23 12:00:11 ssuominen Exp $

EAPI=3
inherit xorg-2 multilib-native

EGIT_REPO_URI="git://anongit.freedesktop.org/git/xorg/lib/libXRes"
DESCRIPTION="X.Org XRes library"

KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXext[lib32?]
	x11-proto/xextproto
	x11-proto/resourceproto"
DEPEND="${RDEPEND}"

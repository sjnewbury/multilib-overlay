# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit x-modular multilib-native

EGIT_REPO_URI="git://anongit.freedesktop.org/git/xorg/lib/libXRes"
DESCRIPTION="X.Org XRes library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"

RDEPEND="x11-libs/libX11[lib32?]
	x11-libs/libXext[lib32?]
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/resourceproto"
